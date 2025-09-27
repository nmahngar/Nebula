import SwiftUI
import CoreData

struct DailyView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var calendarManager: CalendarManager
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        VStack(spacing: NebulaTheme.Spacing.lg) {
            // Header
            Text("Today's Schedule")
                .font(NebulaTheme.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(NebulaTheme.Colors.textPrimary)
                .padding(.top, NebulaTheme.Spacing.lg)
            
            ScrollView {
                VStack(spacing: NebulaTheme.Spacing.md) {
                    // Calendar Events Section
                    if !calendarEvents.isEmpty {
                        VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(NebulaTheme.Colors.accentBlue)
                                Text("Calendar Events")
                                    .font(NebulaTheme.Typography.headline)
                                    .foregroundColor(NebulaTheme.Colors.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, NebulaTheme.Spacing.md)
                            
                            ForEach(calendarEvents, id: \.id) { event in
                                CalendarEventRow(event: event)
                            }
                        }
                        .padding(.horizontal, NebulaTheme.Spacing.md)
                    }
                    
                    // Tasks Section
                    VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                        HStack {
                            Image(systemName: "checklist")
                                .foregroundColor(NebulaTheme.Colors.nebulaAccent)
                            Text("Tasks")
                                .font(NebulaTheme.Typography.headline)
                                .foregroundColor(NebulaTheme.Colors.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, NebulaTheme.Spacing.md)
                        
                        ForEach(todayTasks, id: \.id) { task in
                            TaskRow(task: task, taskManager: taskManager)
                        }
                    }
                    .padding(.horizontal, NebulaTheme.Spacing.md)
                }
            }
            
            Button("Add New Task") {
                taskManager.showingAddTaskSheet = true
            }
            .buttonStyle(CosmicButtonStyle())
            .padding(.bottom, NebulaTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NebulaTheme.Colors.backgroundPrimary)
    }
    
    private var todayTasks: [TaskEntity] {
        taskManager.tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: Date()) }
    }
    
    private var calendarEvents: [CalendarEventViewModel] {
        calendarManager.eventsForDate(Date()).map { CalendarEventViewModel(event: $0) }
    }

    private func deleteTask(offsets: IndexSet) {
        withAnimation {
            offsets.map { taskManager.tasks[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TaskRow: View {
    @ObservedObject var task: TaskEntity
    @ObservedObject var taskManager: TaskManager
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        HStack {
            Button(action: toggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? NebulaTheme.Colors.textTertiary : NebulaTheme.Colors.textPrimary)
                Text(task.desc)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(task.priority.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(task.priority.color.opacity(0.2))
                .cornerRadius(5)
                .foregroundColor(task.priority.color)
        }
        .padding(.vertical, 5)
        .background(NebulaTheme.Colors.backgroundTertiary.opacity(0.5))
        .cornerRadius(10)
        .onTapGesture {
            taskManager.selectedTask = task
        }
    }

    private func toggleCompletion() {
        task.isCompleted.toggle()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


struct CalendarEventRow: View {
    let event: CalendarEventViewModel
    
    var body: some View {
        HStack(spacing: NebulaTheme.Spacing.sm) {
            // Time indicator
            VStack(alignment: .leading, spacing: 2) {
                if event.isAllDay {
                    Text("All Day")
                        .font(NebulaTheme.Typography.caption)
                        .foregroundColor(NebulaTheme.Colors.textSecondary)
                } else {
                    Text(event.formattedTimeRange)
                        .font(NebulaTheme.Typography.caption)
                        .foregroundColor(NebulaTheme.Colors.textSecondary)
                }
            }
            .frame(width: 80, alignment: .leading)
            
            // Event details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(NebulaTheme.Typography.headline)
                    .foregroundColor(NebulaTheme.Colors.textPrimary)
                    .lineLimit(1)
                
                if let location = event.location, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(NebulaTheme.Colors.textTertiary)
                        Text(location)
                            .font(NebulaTheme.Typography.caption)
                            .foregroundColor(NebulaTheme.Colors.textTertiary)
                            .lineLimit(1)
                    }
                }
                
                Text(event.calendarTitle)
                    .font(NebulaTheme.Typography.caption)
                    .foregroundColor(event.color)
            }
            
            Spacer()
            
            // Calendar color indicator
            Circle()
                .fill(event.color)
                .frame(width: 12, height: 12)
        }
        .padding(NebulaTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: NebulaTheme.CornerRadius.medium)
                .fill(NebulaTheme.Colors.backgroundTertiary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: NebulaTheme.CornerRadius.medium)
                        .stroke(event.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CosmicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(gradient: Gradient(colors: [NebulaTheme.Colors.nebulaSecondary, NebulaTheme.Colors.nebulaAccent]), startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}