//
//  ContentView.swift
//  Ascension_Habit_Builder
//
//  Created by Luke Downie on 3/5/26.
//

import SwiftUI
import SwiftData

// MARK: - Design Colors (from reference)
struct AscensionColors {
    static let background = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let accent = Color(red: 0.95, green: 0.78, blue: 0.25)
    static let primary = Color.black
    static let secondary = Color.gray
    static let completedButton = Color(red: 0.95, green: 0.65, blue: 0.72)
    static let dateSelectorBackground = Color(red: 0.96, green: 0.95, blue: 0.93)
    static let finishedTaskRed = Color(red: 0.85, green: 0.2, blue: 0.25)
    static let completedGreen = Color(red: 0.2, green: 0.85, blue: 0.35)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.sortOrder) private var tasks: [Task]
    
    @AppStorage("dev_streakCount") private var streakCount: Int = 0
    @AppStorage("dev_isTaskCompleted") private var isTaskCompleted: Bool = false
    @State private var showQuoteOverlay: Bool = false
    @State private var displayedQuote: Quote?
    
    private let calendar = Calendar.current
    private var weekDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-2...2).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AscensionColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                // Header
                headerView
                
                // Date selector
                dateSelectorView
                
                // Main content: Streak circle + Completed button
                ScrollView {
                    VStack(spacing: 32) {
                        streakCircleView
                        
                        completedButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
            }
            
                // Bottom navigation bar
                bottomNavBar
            }
            .overlay {
                if showQuoteOverlay {
                    quoteOverlay
                }
            }
        }
        .task {
            if tasks.isEmpty {
                for (index, prompt) in Task.defaultPrompts.enumerated() {
                    modelContext.insert(Task(prompt: prompt, sortOrder: index))
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AscensionColors.primary)
                    .frame(width: 40, height: 40)
                    .background(AscensionColors.dateSelectorBackground)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Ascension")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AscensionColors.primary)
            
            Spacer()
            
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Date Selector
    private var dateSelectorView: some View {
        HStack(spacing: 12) {
            Spacer(minLength: 0)
            ForEach(weekDates, id: \.self) { date in
                datePill(for: date)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(AscensionColors.dateSelectorBackground)
    }
    
    private func datePill(for date: Date) -> some View {
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        let dayFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "EEE"
            return f
        }()
        let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "d"
            return f
        }()
        
        return VStack(spacing: 4) {
            Text(dayFormatter.string(from: date))
                .font(.system(size: 12, weight: isToday ? .semibold : .regular))
            Text(dateFormatter.string(from: date))
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
        }
        .foregroundStyle(isToday ? .white : AscensionColors.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Group {
                if isToday {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AscensionColors.primary)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AscensionColors.accent.opacity(0.6), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.clear))
                }
            }
        )
    }
    
    // MARK: - Streak Circle
    private var streakCircleView: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(AscensionColors.primary.opacity(0.2), lineWidth: 12)
                    .frame(width: 180, height: 180)
                
                // Progress ring (cycles 1–7 while count keeps increasing)
                Circle()
                    .trim(from: 0, to: Double((streakCount - 1) % 7 + 1) / 7.0)
                    .stroke(AscensionColors.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(streakCount)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(AscensionColors.primary)
                    
                    Text("day streak")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AscensionColors.secondary)
                }
            }
            
            Text("Keep it up!")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AscensionColors.secondary)
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Completed Button
    private var completedButton: some View {
        Button(action: {
            displayedQuote = InspirationalQuotes.random
            withAnimation(.easeInOut(duration: 0.25)) {
                isTaskCompleted = true
                showQuoteOverlay = true
                streakCount += 1
            }
        }) {
            Text(isTaskCompleted ? "Completed" : "I Did It")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isTaskCompleted ? AscensionColors.primary : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isTaskCompleted ? AscensionColors.completedGreen : AscensionColors.finishedTaskRed)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(isTaskCompleted)
    }
    
    // MARK: - Quote Overlay
    private var quoteOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            if let quote = displayedQuote {
                VStack(spacing: 16) {
                    Text(quote.text)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("— \(quote.author)")
                        .font(.system(size: 16, weight: .regular))
                        .italic()
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.horizontal, 40)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showQuoteOverlay = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                    }
                    .padding(24)
                }
                Spacer()
            }
        }
        .transition(.opacity)
        .animation(.easeIn(duration: 0.3), value: showQuoteOverlay)
    }
    
    // MARK: - Bottom Nav Bar
    private var bottomNavBar: some View {
        HStack(spacing: 0) {
            NavigationLink(destination: TaskLibraryView()) {
                Image(systemName: "rectangle.split.3x1")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Center - navigate to Task Library and open add task sheet
            NavigationLink(destination: TaskLibraryView(openAddTaskOnAppear: true)) {
                ZStack {
                    Circle()
                        .fill(AscensionColors.completedButton)
                        .frame(width: 65, height: 65)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .offset(y: -12)
            
            Spacer()
            
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AscensionColors.primary)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private func navBarButton(icon: String) -> some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Task.self], inMemory: true)
}
