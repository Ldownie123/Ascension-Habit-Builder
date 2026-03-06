import SwiftUI

// MARK: - View Model
struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

struct AscensionDashboard: View {
    @State private var selectedDate = Date()
    @State private var streakCount: Int = 76
    @State private var weeklyProgress: Int = 4
    @State private var isTaskCompleted: Bool = false
    @State private var showQuote: Bool = false
    
    @State private var pendingTasks = [TaskItem(title: "15m Mindfulness Meditation", isCompleted: false)]
    @State private var completedTasks = [TaskItem(title: "Drink 2L Water", isCompleted: true)]
    
    let daysRange: [Date] = (0..<14).compactMap { Calendar.current.date(byAdding: .day, value: $0 - 3, to: Date()) }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // CALENDAR
                calendarHeader.padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 40) {
                        // STREAK
                        streakModule.padding(.top, 20)
                        // ACTION
                        actionZone
                        // TASKS
                        taskStack
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .fullScreenCover(isPresented: $showQuote) {
            QuoteMomentView()
        }
    }
    
    private var calendarHeader: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(daysRange, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    VStack(spacing: 8) {
                        Text(date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(isSelected ? .white : .gray)
                        Text(date.formatted(.dateTime.day()))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isSelected ? .black : .white)
                            .frame(width: 40, height: 40)
                            .background(isSelected ? Color.cyan : Color.clear)
                            .clipShape(Capsule())
                    }
                    .onTapGesture { withAnimation { selectedDate = date } }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 80)
    }
    
    private var streakModule: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 12, lineCap: .round, dash: [2, 40]))
                .frame(width: 200, height: 200)
            Circle()
                .trim(from: 0, to: CGFloat(weeklyProgress) / 7.0)
                .stroke(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
            VStack {
                Text("\(streakCount)").font(.system(size: 60, weight: .bold, design: .rounded))
                Text("STREAK").font(.caption).bold().tracking(2).foregroundStyle(.gray)
            }
        }
    }

    private var actionZone: some View {
        Group {
            if !isTaskCompleted {
                Button(action: {
                    withAnimation { isTaskCompleted = true; streakCount += 1 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showQuote = true }
                }) {
                    Text("COMPLETE ASCENSION")
                        .font(.headline).bold()
                        .frame(maxWidth: .infinity).frame(height: 60)
                        .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                }
            } else {
                Text("✓ DAY COMPLETE").font(.headline).foregroundStyle(.cyan)
            }
        }
    }

    private var taskStack: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("TODAY'S PROGRESS").font(.caption2).bold().foregroundStyle(.gray)
            ForEach(pendingTasks) { task in taskRow(task, active: true) }
            ForEach(completedTasks) { task in taskRow(task, active: false) }
        }
    }

    private func taskRow(_ task: TaskItem, active: Bool) -> some View {
        HStack {
            Image(systemName: active ? "circle" : "checkmark.circle.fill")
            Text(task.title).strikethrough(!active)
            Spacer()
        }
        .padding().background(active ? Color.white.opacity(0.1) : Color.clear).cornerRadius(10)
    }
}

struct QuoteMomentView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack { Color.black.ignoresSafeArea(); Button("Continue") { dismiss() }.tint(.cyan) }
    }
}

// LEGACY PREVIEW SUPPORT (Tell your buddy to look here)
struct AscensionDashboard_Previews: PreviewProvider {
    static var previews: some View {
        AscensionDashboard()
            .preferredColorScheme(.dark)
    }
}