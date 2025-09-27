import SwiftUI

struct FocusView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var calendarManager: CalendarManager
    
    var body: some View {
        VStack {
            Text("Focus View")
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
    FocusView(taskManager: TaskManager(context: PersistenceController.shared.container.viewContext), calendarManager: CalendarManager())
}