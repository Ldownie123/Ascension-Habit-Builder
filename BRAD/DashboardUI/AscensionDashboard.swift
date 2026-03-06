//
//  AscensionDashboard.swift
//  Ascension
//
//  Ascension Dual-Sync Protocol — SwiftUI + HTML in lockstep.
//

import SwiftUI

// MARK: - Design Tokens
private enum AscensionColors {
    static let sand = Color(hex: "F5E6CE")
    static let accentBlue = Color(hex: "35C2FF")
    static let accentRed = Color(hex: "E24D4D")
    static let charcoal = Color(hex: "111111")
    static let neutral = Color(hex: "CECECE")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Models
struct DayItem: Identifiable {
    let id = UUID()
    let dayName: String
    let date: Int
    let status: DayStatus
    enum DayStatus { case past, today, future }
}

struct TaskItem: Identifiable {
    let id: UUID
    let name: String
    let time: String?
    let completed: Bool
    init(id: UUID = UUID(), name: String, time: String?, completed: Bool) {
        self.id = id
        self.name = name
        self.time = time
        self.completed = completed
    }
}

// MARK: - Date Navigation
struct DateNavigationView: View {
    let days: [DayItem]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(days) { day in
                    VStack(spacing: 2) {
                        Text(day.dayName)
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(day.status == .today ? Color.white.opacity(0.8) : day.status == .past ? AscensionColors.charcoal.opacity(0.6) : AscensionColors.charcoal.opacity(0.3))
                        Text("\(day.date)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(day.status == .today ? .white : day.status == .past ? AscensionColors.charcoal.opacity(0.8) : AscensionColors.charcoal.opacity(0.3))
                    }
                    .frame(width: 48, height: 56)
                    .background(day.status == .today ? AscensionColors.charcoal : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Streak Ring (7 segments, weekly progress, resets every 7 days)
struct StreakRingView: View {
    let streak: Int
    let weeklyProgress: Int
    let isFailed: Bool
    private let size: CGFloat = 260
    private let strokeWidth: CGFloat = 14
    private let radius: CGFloat = 124
    // 300° arc (slightly incomplete), 7 segments = ~42.86° each
    private let arcAngle: Double = 300
    private let segmentCount = 7

    var body: some View {
        let wp = isFailed ? 0 : min(weeklyProgress, 7)
        ZStack {
            ForEach(0..<segmentCount, id: \.self) { i in
                segmentPath(index: i)
                    .stroke(
                        segmentColor(i: i, filled: i < wp),
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .shadow(color: (i < wp ? AscensionColors.accentBlue : .clear).opacity(0.5), radius: 6)
            }
            VStack(spacing: 4) {
                Text(isFailed ? "0" : "\(streak)")
                    .font(.system(size: 60, weight: .black))
                    .tracking(-2)
                    .foregroundStyle(isFailed ? AscensionColors.accentRed : AscensionColors.charcoal)
                Text("DAY STREAK")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.2)
                    .foregroundStyle(AscensionColors.charcoal.opacity(0.6))
                Text("\(wp)/7 THIS WEEK")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(0.1)
                    .foregroundStyle(AscensionColors.charcoal.opacity(0.45))
            }
        }
        .padding(.vertical, 32)
        Text(isFailed ? "Discipline must be rebuilt." : "Stay disciplined today.")
            .font(.system(size: 14, weight: .medium))
            .italic()
            .foregroundStyle(AscensionColors.charcoal.opacity(0.5))
            .padding(.top, 32)
    }

    private func segmentColor(i: Int, filled: Bool) -> Color {
        if isFailed && i == 0 { return AscensionColors.accentRed }
        return filled ? AscensionColors.accentBlue : AscensionColors.neutral.opacity(0.4)
    }

    private func segmentPath(index: Int) -> Path {
        let segAngle = arcAngle / Double(segmentCount)
        let startDeg = -90.0 + Double(index) * segAngle
        let endDeg = startDeg + segAngle
        let startRad = startDeg * .pi / 180
        let endRad = endDeg * .pi / 180
        let cx = size / 2
        let cy = size / 2
        let x1 = cx + radius * cos(startRad)
        let y1 = cy + radius * sin(startRad)
        let x2 = cx + radius * cos(endRad)
        let y2 = cy + radius * sin(endRad)
        var path = Path()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addArc(center: CGPoint(x: cx, y: cy), radius: radius, startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: true)
        return path
    }
}

// MARK: - Active Task Card
struct ActiveTaskCardView: View {
    let taskName: String
    let onComplete: () -> Void
    let onSkip: () -> Void
    let isFailed: Bool

    var body: some View {
        if isFailed {
            failedCard
        } else {
            activeCard
        }
    }

    private var failedCard: some View {
        VStack(spacing: 8) {
            Text("TASK FAILED")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(AscensionColors.accentRed.opacity(0.8))
            Text("Phone access restored.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AscensionColors.charcoal)
            Text("Your streak has been reset. Return tomorrow to begin again.")
                .font(.system(size: 14))
                .foregroundStyle(AscensionColors.charcoal.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.4), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .padding(.horizontal, 20)
    }

    private var activeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CURRENT TASK")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(AscensionColors.charcoal.opacity(0.4))
                .padding(.bottom, 16)
            HStack(spacing: 12) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(AscensionColors.sand)
                    .clipShape(Circle())
                    .foregroundStyle(AscensionColors.charcoal)
                Text(taskName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AscensionColors.charcoal)
            }
            .padding(.bottom, 32)
            HStack(spacing: 12) {
                Button(action: onComplete) {
                    Text("Complete Task")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AscensionColors.accentBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                Button(action: onSkip) {
                    Text("Skip Task")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AscensionColors.accentRed)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .background(.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.4), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .padding(.horizontal, 20)
    }
}

// MARK: - Completed Tasks List
struct CompletedTasksListView: View {
    let tasks: [TaskItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TODAY'S PROGRESS")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(AscensionColors.charcoal.opacity(0.4))
                .padding(.horizontal, 4)
            VStack(spacing: 16) {
                ForEach(tasks) { task in
                    HStack {
                        HStack(spacing: 12) {
                            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(task.completed ? AscensionColors.accentBlue : AscensionColors.neutral)
                            Text(task.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(task.completed ? AscensionColors.charcoal : AscensionColors.charcoal.opacity(0.6))
                        }
                        Spacer()
                        if let time = task.time {
                            Text(time)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AscensionColors.charcoal.opacity(0.4))
                        }
                    }
                    .opacity(task.completed ? 1 : 0.4)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
    }
}

// MARK: - Bottom Navigation
struct BottomNavigationView: View {
    let activeTab: Int

    var body: some View {
        HStack(spacing: 0) {
            navItem(icon: "square.grid.2x2", label: "Dashboard", active: activeTab == 0)
            navItem(icon: "checklist", label: "Tasks", active: activeTab == 1)
            navItem(icon: "chart.bar", label: "Stats", active: activeTab == 2)
            navItem(icon: "gearshape", label: "Settings", active: activeTab == 3)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.white.opacity(0.9))
        .overlay(Rectangle().frame(height: 1).foregroundStyle(AscensionColors.neutral.opacity(0.3)), alignment: .top)
    }

    private func navItem(icon: String, label: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: active ? .semibold : .regular))
                .foregroundStyle(active ? AscensionColors.accentBlue : AscensionColors.neutral)
            Text(label)
                .font(.system(size: 10, weight: active ? .bold : .medium))
                .foregroundStyle(active ? AscensionColors.charcoal : AscensionColors.neutral)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Main Dashboard
struct AscensionDashboard: View {
    @State private var isFailed = false
    @State private var streak = 4
    @State private var weeklyProgress = 4
    @State private var tasks: [TaskItem] = [
        TaskItem(name: "Drink Water", time: "8:15 AM", completed: true),
        TaskItem(name: "Morning Stretch", time: "9:30 AM", completed: true),
        TaskItem(name: "Read for 15 Minutes", time: "12:45 PM", completed: true),
        TaskItem(name: "Evening Journal", time: nil, completed: false),
    ]
    private let days: [DayItem] = [
        DayItem(dayName: "FRI", date: 9, status: .past),
        DayItem(dayName: "SAT", date: 10, status: .past),
        DayItem(dayName: "SUN", date: 11, status: .past),
        DayItem(dayName: "MON", date: 12, status: .past),
        DayItem(dayName: "TUE", date: 13, status: .today),
        DayItem(dayName: "WED", date: 14, status: .future),
        DayItem(dayName: "THU", date: 15, status: .future),
        DayItem(dayName: "FRI", date: 16, status: .future),
        DayItem(dayName: "SAT", date: 17, status: .future),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            AscensionColors.sand
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    header
                    DateNavigationView(days: days)
                    StreakRingView(streak: streak, weeklyProgress: weeklyProgress, isFailed: isFailed)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    ActiveTaskCardView(
                        taskName: "Complete a 10 Minute Walk",
                        onComplete: handleComplete,
                        onSkip: handleSkip,
                        isFailed: isFailed
                    )
                    CompletedTasksListView(tasks: tasks)
                }
                .padding(.bottom, 140)
            }
            BottomNavigationView(activeTab: 0)
        }
    }

    private var header: some View {
        Text("ASCENSION")
            .font(.system(size: 12, weight: .bold))
            .tracking(0.3)
            .foregroundStyle(AscensionColors.charcoal.opacity(0.8))
            .padding(.top, 48)
            .padding(.bottom, 8)
    }

    private func handleComplete() {
        guard !isFailed else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            weeklyProgress = min(7, weeklyProgress + 1)
            streak += 1
            if let idx = tasks.firstIndex(where: { !$0.completed }) {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                tasks[idx] = TaskItem(id: tasks[idx].id, name: tasks[idx].name, time: formatter.string(from: Date()), completed: true)
            }
        }
    }

    private func handleSkip() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isFailed = true
            streak = 0
            weeklyProgress = 0
        }
    }
}

// MARK: - Preview
#Preview {
    AscensionDashboard()
}

struct AscensionDashboard_Previews: PreviewProvider {
    static var previews: some View {
        AscensionDashboard()
    }
}
