import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: TaskEntity
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var priority: TaskPriority
    @State private var category: TaskCategory
    @State private var isCompleted: Bool

    init(task: TaskEntity, taskManager: TaskManager) {
        self.task = task
        self.taskManager = taskManager
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.desc)
        _dueDate = State(initialValue: task.dueDate)
        _priority = State(initialValue: task.priority)
        _category = State(initialValue: task.category)
        _isCompleted = State(initialValue: task.isCompleted)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Task Details")
                .font(.title)
                .foregroundColor(.white)

            TextField("Task Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
                .colorScheme(.dark)

            Picker("Priority", selection: $priority) {
                ForEach(TaskPriority.allCases) { p in
                    Text(p.rawValue).tag(p)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Picker("Category", selection: $category) {
                ForEach(TaskCategory.allCases) { c in
                    Text(c.rawValue).tag(c)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)

            Toggle(isOn: $isCompleted) {
                Text("Completed")
            }
            .toggleStyle(SwitchToggleStyle())
            .padding(.horizontal)

            HStack {
                Button("Delete") {
                    taskManager.deleteTask(task: task)
                    dismiss()
                }
                .buttonStyle(CosmicButtonStyle())
                .accentColor(.red)

                Button("Save Changes") {
                    taskManager.updateTask(
                        task: task,
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        priority: priority,
                        category: category,
                        isCompleted: isCompleted
                    )
                    dismiss()
                }
                .buttonStyle(CosmicButtonStyle())
            }
        }
        .padding()
        .background(NebulaTheme.Colors.backgroundSecondary.opacity(0.9))
        .cornerRadius(15)
    }
}
