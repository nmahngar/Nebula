import Foundation
import CoreData
import SwiftUI

enum ViewMode: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case focus = "Focus"

    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .daily: return "calendar.day.timeline.leading"
        case .weekly: return "calendar.week.number.ar"
        case .monthly: return "calendar"
        case .focus: return "hourglass"
        }
    }
}

class TaskManager: ObservableObject {
    @Published var isSidebarCollapsed: Bool = false
    @Published var currentViewMode: ViewMode = .daily
    @Published var showingAddTaskSheet: Bool = false
    @Published var selectedTask: TaskEntity? // For TaskDetailView

    var viewContext: NSManagedObjectContext

    @Published var tasks: [TaskEntity] = []

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchTasks()
    }

    func toggleSidebar() {
        isSidebarCollapsed.toggle()
    }

    func fetchTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            tasks = try viewContext.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }

    func addTask(title: String, description: String, dueDate: Date, priority: TaskPriority, category: TaskCategory) {
        let newTask = TaskEntity(context: viewContext)
        newTask.title = title
        newTask.desc = description
        newTask.dueDate = dueDate
        newTask.priority = priority
        newTask.category = category
        newTask.isCompleted = false
        newTask.creationDate = Date()

        do {
            try viewContext.save()
            fetchTasks() // Refresh tasks after adding
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func updateTask(task: TaskEntity, title: String, description: String, dueDate: Date, priority: TaskPriority, category: TaskCategory, isCompleted: Bool) {
        task.title = title
        task.desc = description
        task.dueDate = dueDate
        task.priority = priority
        task.category = category
        task.isCompleted = isCompleted

        do {
            try viewContext.save()
            fetchTasks() // Refresh tasks after updating
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func deleteTask(task: TaskEntity) {
        viewContext.delete(task)
        do {
            try viewContext.save()
            fetchTasks() // Refresh tasks after deleting
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
