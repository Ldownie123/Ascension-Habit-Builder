import SwiftUI

// MARK: - View Model / State Mock
struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

struct AscensionDashboard: View {
    // State management for the prototype
    @State private var selectedDate = Date()
    @State private var streakCount: Int = 76
    @State private var weeklyProgress: Int = 4 // 4 out of 7 days
    @State private var isTaskCompleted: Bool = false
    @State private var showQuote: Bool = false
    
    // Mock Data
    @State private var pendingTasks = [TaskItem(title: "15m Mindfulness Meditation", isCompleted: false)]
    @State private var completedTasks = [TaskItem(title: "Drink 2L Water", isCompleted: true)]
    
    let calendar = Calendar.current
    let daysRange: [Date] = (0..<14).compactMap { Calendar.current.date(byAdding: .day, value: $0 - 3, to: Date()) }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: 1. HORIZON CALENDAR
                calendarHeader
                    .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 40) {
                        
                        // MARK: 2. ASCENSION HALO (STREAK)
                        streakModule
                            .padding(.top, 20)
                        
                        // MARK: 3. ACTION ZONE
                        actionZone
                        
                        // MARK: 4. TASK STACK
                        taskStack
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .fullScreenCover(isPresented: $showQuote) {
            QuoteMomentView() // Placeholder for your existing quote view
        }
    }
    
    // MARK: - Sub-Components
    
    private var calendarHeader: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 15) {
                    ForEach(daysRange, id: \.self) { date in
                        let isToday = calendar.isDateInToday(date)
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        
                        VStack(spacing: 8) {
                            Text(date.format("EEE").uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(isSelected ? .white : .gray)
                            
                            Text(date.format("d"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(isSelected ? .black : .white)
                                .frame(width: 40, height: 40)
                                .background(
                                    ZStack {
                                        if isSelected {
                                            Capsule().fill(Color.ascensionTeal)
                                        } else if isToday {
                                            Capsule().stroke(Color.ascensionTeal, lineWidth: 1)
                                        }
                                    }
                                )
                        }
                        .opacity(isSelected ? 1.0 : 0.5)
                        .onTapGesture {
                            withAnimation(.spring()) { selectedDate = date }
                        }
                        .id(date)
                    }
                }
                .padding(.horizontal, 20)
                .onAppear {
                    proxy.scrollTo(daysRange[3], anchor: .center)
                }
            }
        }
        .frame(height: 100)
    }
    
    private var streakModule: some View {
        ZStack {
            // The 7-Segment Ring
            Circle()
                .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 12, lineCap: .round, dash: [2, 45])) // Placeholder segments
                .frame(width: 220, height: 220)
            
            // Progress segments
            Circle()
                .trim(from: 0, to: CGFloat(weeklyProgress) / 7.0)
                .stroke(
                    LinearGradient(colors: [.ascensionTeal, .ascensionBlue], startPoint: .top, endPoint: .bottom),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)
                .shadow(color: .ascensionTeal.opacity(0.3), radius: 10)
            
            VStack(spacing: 0) {
                Text("\(streakCount)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("DAY STREAK")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.gray)
                    .tracking(2)
            }
        }
    }
    
    private var actionZone: some View {
        VStack(spacing: 12) {
            if !isTaskCompleted {
                Button(action: completeDay) {
                    Text("Complete Ascension")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(colors: [.ascensionTeal, .ascensionBlue], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: .ascensionTeal.opacity(0.4), radius: 15, y: 5)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Day Complete")
                }
                .font(.headline)
                .foregroundStyle(.ascensionTeal)
                .frame(height: 60)
            }
        }
    }
    
    private var taskStack: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("TODAY'S PROGRESS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.gray)
                .tracking(1.5)
            
            ForEach(pendingTasks) { task in
                taskRow(task, active: true)
            }
            
            ForEach(completedTasks) { task in
                taskRow(task, active: false)
            }
        }
    }
    
    private func taskRow(_ task: TaskItem, active: Bool) -> some View {
        HStack(spacing: 15) {
            Image(systemName: active ? "circle" : "checkmark.circle.fill")
                .foregroundStyle(active ? .gray : .ascensionTeal)
                .font(.title3)
            
            Text(task.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(active ? .white : .gray)
                .strikethrough(!active)
            
            Spacer()
            
            Text(active ? "PENDING" : "DONE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding()
        .background(active ? Color.white.opacity(0.05) : Color.clear)
        .cornerRadius(12)
    }
    
    // MARK: - Logic
    
    private func completeDay() {
        withAnimation(.spring()) {
            isTaskCompleted = true
            streakCount += 1
            if let task = pendingTasks.first {
                completedTasks.insert(TaskItem(title: task.title, isCompleted: true), at: 0)
                pendingTasks.removeAll()
            }
        }
        // Delay the quote to let the animation finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showQuote = true
        }
    }
}

// MARK: - Extensions & Helpers

extension Color {
    static let ascensionTeal = Color(red: 46/255, green: 237/255, blue: 199/255)
    static let ascensionBlue = Color(red: 29/255, green: 161/255, blue: 242/255)
}

extension Date {
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

struct QuoteMomentView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                Text("“The soul always knows what to do to heal itself. The challenge is to silence the mind.”")
                    .font(.title2)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(40)
                
                Button("Continue") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(.ascensionTeal)
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    AscensionDashboard()
}