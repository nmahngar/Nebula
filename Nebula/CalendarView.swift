import SwiftUI

struct CalendarView: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        VStack {
            Text("Calendar View")
                .font(NebulaTheme.Typography.largeTitle)
                .foregroundColor(NebulaTheme.Colors.textPrimary)
            
            Text("Coming Soon")
                .font(NebulaTheme.Typography.headline)
                .foregroundColor(NebulaTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NebulaTheme.Colors.backgroundSecondary.opacity(0.3))
    }
}

#Preview {
    CalendarView(taskManager: TaskManager(context: PersistenceController.shared.container.viewContext))
}
