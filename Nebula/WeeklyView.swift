import SwiftUI

struct WeeklyView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var calendarManager: CalendarManager
    @State private var currentWeek = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(taskManager: TaskManager, calendarManager: CalendarManager) {
        self.taskManager = taskManager
        self.calendarManager = calendarManager
        dateFormatter.dateFormat = "EEEE"
    }
    
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private func tasksForDay(_ date: Date) -> [TaskEntity] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        return taskManager.tasks.filter { task in
            let taskDate = calendar.startOfDay(for: task.dueDate)
            return taskDate >= startOfDay && taskDate < endOfDay
        }
    }
    
    var body: some View {
        VStack(spacing: NebulaTheme.Spacing.lg) {
            // Header with week navigation
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Text(weekRangeText)
                    .font(NebulaTheme.Typography.title)
                    .foregroundColor(NebulaTheme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, NebulaTheme.Spacing.lg)
            
            // Week grid
            VStack(spacing: 0) {
                // Day headers
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        VStack(spacing: NebulaTheme.Spacing.sm) {
                            Text(dateFormatter.string(from: day))
                                .font(NebulaTheme.Typography.caption)
                                .foregroundColor(NebulaTheme.Colors.textSecondary)
                            
                            Text("\(calendar.component(.day, from: day))")
                                .font(NebulaTheme.Typography.headline)
                                .foregroundColor(isToday(day) ? NebulaTheme.Colors.accentBlue : NebulaTheme.Colors.textPrimary)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(isToday(day) ? NebulaTheme.Colors.accentBlue.opacity(0.2) : Color.clear)
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, NebulaTheme.Spacing.sm)
                    }
                }
                .background(NebulaTheme.Colors.backgroundTertiary.opacity(0.5))
                
                // Tasks for each day
                HStack(alignment: .top, spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                            ForEach(tasksForDay(day), id: \.id) { task in
                                TaskCard(task: task, taskManager: taskManager)
                            }
                            
                            if tasksForDay(day).isEmpty {
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(NebulaTheme.Spacing.sm)
                        .background(
                            Rectangle()
                                .fill(NebulaTheme.Colors.backgroundSecondary.opacity(0.3))
                                .overlay(
                                    Rectangle()
                                        .stroke(NebulaTheme.Colors.backgroundTertiary, lineWidth: 0.5)
                                )
                        )
                    }
                }
            }
            .background(NebulaTheme.Colors.backgroundSecondary.opacity(0.2))
            .cornerRadius(NebulaTheme.CornerRadius.large)
            .padding(.horizontal, NebulaTheme.Spacing.lg)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NebulaTheme.Colors.backgroundPrimary)
    }
    
    private var weekRangeText: String {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? currentWeek
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func previousWeek() {
        currentWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
    }
    
    private func nextWeek() {
        currentWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
    }
}

struct TaskCard: View {
    @ObservedObject var task: TaskEntity
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)
                
                Text(task.title)
                    .font(NebulaTheme.Typography.caption)
                    .foregroundColor(NebulaTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
            }
            
            if !task.desc.isEmpty {
                Text(task.desc)
                    .font(.caption2)
                    .foregroundColor(NebulaTheme.Colors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(task.category.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(task.category.color.opacity(0.3), lineWidth: 1)
                )
        )
        .onTapGesture {
            taskManager.selectedTask = task
        }
    }
}

#Preview {
    WeeklyView(taskManager: TaskManager(context: PersistenceController.shared.container.viewContext), calendarManager: CalendarManager())
}
