import Foundation
import CoreData
import SwiftUI

enum TaskPriority: String, CaseIterable, Codable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    var order: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable, Identifiable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case finance = "Finance"
    case learning = "Learning"
    case social = "Social"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .personal: return .purple
        case .health: return .green
        case .finance: return .yellow
        case .learning: return .indigo
        case .social: return .pink
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .learning: return "book.fill"
        case .social: return "person.2.fill"
        case .other: return "folder.fill"
        }
    }
}


// Core Data Task Entity (simplified for initial setup)
extension TaskEntity {
    public var id: UUID { 
        // Use objectID as a stable identifier
        return UUID(uuidString: objectID.uriRepresentation().absoluteString) ?? UUID()
    }
    var title: String { get { title_ ?? "New Task" } set { title_ = newValue } }
    var desc: String { get { desc_ ?? "" } set { desc_ = newValue } }
    var dueDate: Date { get { dueDate_ ?? Date() } set { dueDate_ = newValue } }
    var priority: TaskPriority {
        get { TaskPriority(rawValue: priority_ ?? "low") ?? .low }
        set { priority_ = newValue.rawValue }
    }
    var category: TaskCategory {
        get { TaskCategory(rawValue: category_ ?? "other") ?? .other }
        set { category_ = newValue.rawValue }
    }
    var isCompleted: Bool { get { isCompleted_ } set { isCompleted_ = newValue } }
    var creationDate: Date { get { creationDate_ ?? Date() } set { creationDate_ = newValue } }
}

