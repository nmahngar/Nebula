import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var taskManager: TaskManager
    @StateObject private var calendarManager = CalendarManager()
    @State private var showingAddTask = false
    
    init() {
        _taskManager = StateObject(wrappedValue: TaskManager(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        ZStack {
            CosmicBackground()
            
            HStack(spacing: 0) {
                sidebarView
                mainContentView
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskManager: taskManager)
        }
        .sheet(item: $taskManager.selectedTask) { task in
            TaskDetailView(task: task, taskManager: taskManager)
        }
    }
    
    private var sidebarView: some View {
        SidebarView(taskManager: taskManager)
            .frame(width: taskManager.isSidebarCollapsed ? 60 : 280)
            .animation(.easeInOut(duration: 0.3), value: taskManager.isSidebarCollapsed)
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            topToolbar
            contentArea
        }
    }
    
    private var topToolbar: some View {
        HStack {
            Button(action: { taskManager.toggleSidebar() }) {
                Image(systemName: "sidebar.left")
                    .font(.title2)
                    .foregroundColor(NebulaTheme.Colors.textPrimary)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            viewModeButtons
            
            Spacer()
            
            HStack(spacing: NebulaTheme.Spacing.md) {
                addTaskButton
                nebulaLogo
            }
        }
        .padding(NebulaTheme.Spacing.lg)
        .background(NebulaTheme.Colors.backgroundSecondary.opacity(0.8).blur(radius: 10))
    }
    
    private var viewModeButtons: some View {
        HStack(spacing: NebulaTheme.Spacing.sm) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                viewModeButton(for: mode)
            }
        }
    }
    
    private func viewModeButton(for mode: ViewMode) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                taskManager.currentViewMode = mode
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: mode.icon)
                    .font(.title3)
                Text(mode.rawValue)
                    .font(NebulaTheme.Typography.caption)
            }
            .foregroundColor(taskManager.currentViewMode == mode ? 
                           NebulaTheme.Colors.textPrimary : 
                           NebulaTheme.Colors.textTertiary)
            .padding(.horizontal, NebulaTheme.Spacing.sm)
            .padding(.vertical, NebulaTheme.Spacing.xs)
            .background(
                taskManager.currentViewMode == mode ?
                AnyView(NebulaTheme.Gradients.nebulaAccent) :
                AnyView(Color.clear)
            )
            .cornerRadius(NebulaTheme.CornerRadius.small)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var addTaskButton: some View {
        Button(action: { showingAddTask = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(NebulaTheme.Colors.textPrimary)
                .padding(NebulaTheme.Spacing.sm)
                .background(NebulaTheme.Gradients.nebulaAccent)
                .cornerRadius(NebulaTheme.CornerRadius.medium)
                .nebulaGlow()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var nebulaLogo: some View {
        HStack(spacing: NebulaTheme.Spacing.sm) {
            // Logo circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.2, blue: 0.6),
                            Color(red: 0.6, green: 0.4, blue: 0.8),
                            Color(red: 0.8, green: 0.7, blue: 0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.1, blue: 0.4),
                                    Color(red: 0.4, green: 0.2, blue: 0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.3), radius: 4, x: 0, y: 2)
            
            // "Nebula" text
            Text("Nebula")
                .font(NebulaTheme.Typography.headline)
                .foregroundColor(NebulaTheme.Colors.textPrimary)
                .fontWeight(.medium)
        }
        .padding(.horizontal, NebulaTheme.Spacing.sm)
        .padding(.vertical, NebulaTheme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: NebulaTheme.CornerRadius.medium)
                .fill(NebulaTheme.Colors.backgroundTertiary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: NebulaTheme.CornerRadius.medium)
                        .stroke(NebulaTheme.Colors.nebulaAccent.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var contentArea: some View {
        Group {
            switch taskManager.currentViewMode {
            case .daily: DailyView(taskManager: taskManager, calendarManager: calendarManager)
            case .weekly: WeeklyView(taskManager: taskManager, calendarManager: calendarManager)
            case .monthly: MonthlyView(taskManager: taskManager, calendarManager: calendarManager)
            case .focus: FocusView(taskManager: taskManager, calendarManager: calendarManager)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if calendarManager.authorizationStatus == .notDetermined {
                Task {
                    await calendarManager.requestAccess()
                }
            } else if calendarManager.authorizationStatus == .fullAccess {
                calendarManager.fetchEvents()
            }
        }
    }
}

struct AddTaskView: View {
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority = TaskPriority.medium
    @State private var selectedCategory = TaskCategory.other
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    var body: some View {
        VStack(spacing: NebulaTheme.Spacing.lg) {
            HStack {
                Text("Add New Task")
                    .font(NebulaTheme.Typography.title)
                    .foregroundColor(NebulaTheme.Colors.textPrimary)
                Spacer()
                Button("Cancel") { dismiss() }
                    .foregroundColor(NebulaTheme.Colors.textSecondary)
            }
            
            VStack(spacing: NebulaTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                    Text("Title")
                        .font(NebulaTheme.Typography.headline)
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                    
                    TextField("Enter task title", text: $title)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(NebulaTheme.Spacing.md)
                        .background(NebulaTheme.Colors.backgroundTertiary)
                        .cornerRadius(NebulaTheme.CornerRadius.medium)
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                }
                
                VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                    Text("Description")
                        .font(NebulaTheme.Typography.headline)
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                    
                    TextField("Enter task description", text: $description)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(NebulaTheme.Spacing.md)
                        .background(NebulaTheme.Colors.backgroundTertiary)
                        .cornerRadius(NebulaTheme.CornerRadius.medium)
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                }
                
                HStack(spacing: NebulaTheme.Spacing.md) {
                    VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                        Text("Priority")
                            .font(NebulaTheme.Typography.headline)
                            .foregroundColor(NebulaTheme.Colors.textPrimary)
                        
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(NebulaTheme.Spacing.sm)
                        .background(NebulaTheme.Colors.backgroundTertiary)
                        .cornerRadius(NebulaTheme.CornerRadius.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                        Text("Category")
                            .font(NebulaTheme.Typography.headline)
                            .foregroundColor(NebulaTheme.Colors.textPrimary)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(TaskCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(NebulaTheme.Spacing.sm)
                        .background(NebulaTheme.Colors.backgroundTertiary)
                        .cornerRadius(NebulaTheme.CornerRadius.medium)
                    }
                }
                
                VStack(alignment: .leading, spacing: NebulaTheme.Spacing.sm) {
                    Toggle("Set due date", isOn: $hasDueDate)
                        .font(NebulaTheme.Typography.headline)
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(NebulaTheme.Spacing.sm)
                            .background(NebulaTheme.Colors.backgroundTertiary)
                            .cornerRadius(NebulaTheme.CornerRadius.medium)
                    }
                }
            }
            
            Button(action: {
                let taskDueDate = hasDueDate ? dueDate : nil
                taskManager.addTask(title: title, description: description, dueDate: taskDueDate ?? Date(), priority: selectedPriority, category: selectedCategory)
                dismiss()
            }) {
                Text("Create Task")
                    .font(NebulaTheme.Typography.headline)
                    .foregroundColor(NebulaTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(NebulaTheme.Spacing.md)
                    .background(NebulaTheme.Gradients.nebulaAccent)
                    .cornerRadius(NebulaTheme.CornerRadius.medium)
                    .nebulaGlow()
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(title.isEmpty)
        }
        .padding(NebulaTheme.Spacing.lg)
        .background(NebulaTheme.Colors.backgroundSecondary)
        .cornerRadius(NebulaTheme.CornerRadius.large)
        .frame(width: 500, height: 400)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
