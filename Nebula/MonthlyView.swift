import SwiftUI

struct MonthlyView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var calendarManager: CalendarManager
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(taskManager: TaskManager, calendarManager: CalendarManager) {
        self.taskManager = taskManager
        self.calendarManager = calendarManager
        dateFormatter.dateFormat = "MMMM yyyy"
    }
    
    private var monthDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1) else {
            return []
        }
        
        let firstDay = monthFirstWeek.start
        let lastDay = monthLastWeek.end
        
        var days: [Date] = []
        var currentDay = firstDay
        
        while currentDay < lastDay {
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
        }
        
        return days
    }
    
    private var weekDays: [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }
    
    private func tasksForDay(_ date: Date) -> [TaskEntity] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return taskManager.tasks.filter { task in
            let taskDate = calendar.startOfDay(for: task.dueDate)
            return taskDate >= startOfDay && taskDate < endOfDay
        }
    }
    
    private func taskDensityForDay(_ date: Date) -> Double {
        let tasks = tasksForDay(date)
        let totalTasks = taskManager.tasks.count
        return totalTasks > 0 ? Double(tasks.count) / Double(totalTasks) : 0
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    var body: some View {
        VStack(spacing: NebulaTheme.Spacing.lg) {
            // Header with month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(NebulaTheme.Typography.title)
                    .foregroundColor(NebulaTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, NebulaTheme.Spacing.lg)
            
            // Calendar grid
            VStack(spacing: 0) {
                // Week day headers
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .font(NebulaTheme.Typography.caption)
                            .foregroundColor(NebulaTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, NebulaTheme.Spacing.sm)
                    }
                }
                .background(NebulaTheme.Colors.backgroundTertiary.opacity(0.5))
                
                // Calendar days
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                    ForEach(monthDays, id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            tasks: tasksForDay(date),
                            taskDensity: taskDensityForDay(date),
                            isToday: isToday(date),
                            isCurrentMonth: isCurrentMonth(date),
                            taskManager: taskManager
                        )
                    }
                }
            }
            .background(NebulaTheme.Colors.backgroundSecondary.opacity(0.2))
            .cornerRadius(NebulaTheme.CornerRadius.large)
            .padding(.horizontal, NebulaTheme.Spacing.lg)
            
            // Legend
            HStack(spacing: NebulaTheme.Spacing.lg) {
                HStack(spacing: NebulaTheme.Spacing.sm) {
                    Circle()
                        .fill(NebulaTheme.Colors.accentBlue)
                        .frame(width: 12, height: 12)
                    Text("Today")
                        .font(NebulaTheme.Typography.caption)
                        .foregroundColor(NebulaTheme.Colors.textSecondary)
                }
                
                HStack(spacing: NebulaTheme.Spacing.sm) {
                    Circle()
                        .fill(NebulaTheme.Colors.success)
                        .frame(width: 12, height: 12)
                    Text("High Density")
                        .font(NebulaTheme.Typography.caption)
                        .foregroundColor(NebulaTheme.Colors.textSecondary)
                }
                
                HStack(spacing: NebulaTheme.Spacing.sm) {
                    Circle()
                        .fill(NebulaTheme.Colors.warning)
                        .frame(width: 12, height: 12)
                    Text("Medium Density")
                        .font(NebulaTheme.Typography.caption)
                        .foregroundColor(NebulaTheme.Colors.textSecondary)
                }
                
                HStack(spacing: NebulaTheme.Spacing.sm) {
                    Circle()
                        .fill(NebulaTheme.Colors.textTertiary)
                        .frame(width: 12, height: 12)
                    Text("Low Density")
                        .font(NebulaTheme.Typography.caption)
                        .foregroundColor(NebulaTheme.Colors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, NebulaTheme.Spacing.lg)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NebulaTheme.Colors.backgroundPrimary)
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct CalendarDayView: View {
    let date: Date
    let tasks: [TaskEntity]
    let taskDensity: Double
    let isToday: Bool
    let isCurrentMonth: Bool
    @ObservedObject var taskManager: TaskManager
    
    private let calendar = Calendar.current
    
    private var densityColor: Color {
        if taskDensity > 0.3 {
            return NebulaTheme.Colors.success
        } else if taskDensity > 0.1 {
            return NebulaTheme.Colors.warning
        } else {
            return NebulaTheme.Colors.textTertiary
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Date number
            Text("\(calendar.component(.day, from: date))")
                .font(NebulaTheme.Typography.caption)
                .foregroundColor(isCurrentMonth ? (isToday ? NebulaTheme.Colors.accentBlue : NebulaTheme.Colors.textPrimary) : NebulaTheme.Colors.textTertiary)
                .padding(4)
                .background(
                    Circle()
                        .fill(isToday ? NebulaTheme.Colors.accentBlue.opacity(0.2) : Color.clear)
                )
            
            // Task density indicator
            if !tasks.isEmpty {
                HStack(spacing: 2) {
                    ForEach(0..<min(tasks.count, 3), id: \.self) { index in
                        Circle()
                            .fill(tasks[index].priority.color)
                            .frame(width: 4, height: 4)
                    }
                    
                    if tasks.count > 3 {
                        Text("+\(tasks.count - 3)")
                            .font(.caption2)
                            .foregroundColor(NebulaTheme.Colors.textSecondary)
                    }
                }
            }
            
            // Density glow effect
            if taskDensity > 0 {
                Circle()
                    .fill(densityColor.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .blur(radius: 2)
            }
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(isCurrentMonth ? NebulaTheme.Colors.backgroundSecondary.opacity(0.3) : NebulaTheme.Colors.backgroundTertiary.opacity(0.1))
                .overlay(
                    Rectangle()
                        .stroke(
                            isToday ? NebulaTheme.Colors.accentBlue : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .onTapGesture {
            if !tasks.isEmpty {
                // Show tasks for this day
                // This could open a detail view or filter the daily view
            }
        }
    }
}

#Preview {
    MonthlyView(taskManager: TaskManager(context: PersistenceController.shared.container.viewContext), calendarManager: CalendarManager())
}
