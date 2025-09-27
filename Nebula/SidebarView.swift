import SwiftUI

struct SidebarView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if !taskManager.isSidebarCollapsed {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundColor(NebulaTheme.Colors.nebulaLight)
                        .nebulaGlow()
                    
                    Text("Nebula")
                        .font(NebulaTheme.Typography.title)
                        .foregroundColor(NebulaTheme.Colors.textPrimary)
                        .fontWeight(.bold)
                } else {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(NebulaTheme.Colors.nebulaLight)
                        .nebulaGlow()
                }
            }
            .padding(NebulaTheme.Spacing.lg)
            .background(NebulaTheme.Colors.nebulaPrimary.opacity(0.3).blur(radius: 10))
            
            VStack(spacing: NebulaTheme.Spacing.sm) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    SidebarButton(
                        title: mode.rawValue,
                        icon: mode.icon,
                        isSelected: taskManager.currentViewMode == mode,
                        isCollapsed: taskManager.isSidebarCollapsed
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            taskManager.currentViewMode = mode
                        }
                    }
                }
            }
            .padding(NebulaTheme.Spacing.md)
            
            Spacer()
            
            VStack {
                SidebarButton(
                    title: "Settings",
                    icon: "gearshape.fill",
                    isSelected: showingSettings,
                    isCollapsed: taskManager.isSidebarCollapsed
                ) {
                    showingSettings.toggle()
                }
            }
            .padding(NebulaTheme.Spacing.md)
        }
        .background(NebulaTheme.Gradients.sidebarBackground)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let isCollapsed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: NebulaTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? NebulaTheme.Colors.textPrimary : NebulaTheme.Colors.textSecondary)
                    .frame(width: 20)
                
                if !isCollapsed {
                    Text(title)
                        .font(NebulaTheme.Typography.body)
                        .foregroundColor(isSelected ? NebulaTheme.Colors.textPrimary : NebulaTheme.Colors.textSecondary)
                        .fontWeight(isSelected ? .semibold : .regular)
                }
                
                if !isCollapsed {
                    Spacer()
                }
            }
            .padding(NebulaTheme.Spacing.md)
            .background(isSelected ? NebulaTheme.Colors.nebulaAccent.opacity(0.3) : Color.clear)
            .cornerRadius(NebulaTheme.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    HStack {
        SidebarView(taskManager: TaskManager(context: PersistenceController.shared.container.viewContext))
        Spacer()
    }
    .background(NebulaTheme.Colors.backgroundPrimary)
}
