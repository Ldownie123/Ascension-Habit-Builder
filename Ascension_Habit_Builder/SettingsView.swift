//
//  SettingsView.swift
//  Ascension_Habit_Builder
//
//  Created by Luke Downie on 3/5/26.
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("dev_streakCount") private var streakCount: Int = 0
    @AppStorage("dev_isTaskCompleted") private var isTaskCompleted: Bool = false
    @Query private var items: [Item]
    
    @State private var showResetStreakAlert = false
    @State private var showDebugInfoAlert = false
    
    var body: some View {
        ZStack {
            AscensionColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AscensionColors.primary)
                            .frame(width: 40, height: 40)
                            .background(AscensionColors.dateSelectorBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AscensionColors.primary)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                // Settings list
                ScrollView {
                    VStack(spacing: 0) {
                        settingsSection(title: "General") {
                        SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Daily reminders")
                        SettingsRow(icon: "hand.tap.fill", title: "Haptic Feedback", subtitle: "Vibration on actions")
                        SettingsRow(icon: "speaker.wave.2.fill", title: "Sound", subtitle: "Completion sounds")
                    }
                    
                    settingsSection(title: "Dev Tools") {
                        DevToolButton(icon: "house.fill", title: "Back to Home") {
                            dismiss()
                        }
                        DevToolButton(icon: "plus.circle.fill", title: "Increment Streak") {
                            streakCount = min(7, streakCount + 1)
                        }
                        DevToolButton(icon: "arrow.counterclockwise", title: "Reset Streak") {
                            showResetStreakAlert = true
                        }
                        DevToolButton(icon: "checkmark.circle", title: "Reset Finished Task Button") {
                            isTaskCompleted = false
                        }
                        DevToolButton(icon: "hand.tap.fill", title: "Trigger Haptic") {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                        DevToolButton(icon: "bell.badge.fill", title: "Test Notification") {
                            scheduleTestNotification()
                        }
                        DevToolButton(icon: "doc.badge.plus", title: "Add Test Item") {
                            modelContext.insert(Item(timestamp: Date()))
                        }
                        DevToolButton(icon: "info.circle.fill", title: "Show Debug Info") {
                            showDebugInfoAlert = true
                        }
                    }
                    
                    settingsSection(title: "About") {
                        SettingsRow(icon: "info.circle.fill", title: "About Ascension", subtitle: "Version 1.0")
                    }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarHidden(true)
        .alert("Reset Streak?", isPresented: $showResetStreakAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                streakCount = 0
            }
        } message: {
            Text("This will set your streak to 0.")
        }
        .alert("Debug Info", isPresented: $showDebugInfoAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Streak: \(streakCount)\nItems: \(items.count)\nDate: \(Date().formatted(date: .abbreviated, time: .shortened))")
        }
    }
    
    private func scheduleTestNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Ascension"
            content.body = "Test notification — your reminder is working!"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "dev-test-notification", content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AscensionColors.secondary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(AscensionColors.dateSelectorBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 24)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AscensionColors.accent)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AscensionColors.primary)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AscensionColors.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AscensionColors.secondary.opacity(0.6))
        }
        .padding(16)
    }
}

struct DevToolButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AscensionColors.accent)
                    .frame(width: 32, height: 32)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AscensionColors.primary)
                
                Spacer()
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: Item.self, inMemory: true)
}
