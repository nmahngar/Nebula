import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: NebulaTheme.Spacing.lg) {
            Text("Settings")
                .font(NebulaTheme.Typography.largeTitle)
                .foregroundColor(NebulaTheme.Colors.textPrimary)
            
            Text("Coming Soon")
                .font(NebulaTheme.Typography.headline)
                .foregroundColor(NebulaTheme.Colors.textSecondary)
            
            Button("Close") {
                dismiss()
            }
            .font(NebulaTheme.Typography.headline)
            .foregroundColor(NebulaTheme.Colors.nebulaAccent)
        }
        .padding(NebulaTheme.Spacing.lg)
        .frame(width: 400, height: 300)
        .background(NebulaTheme.Colors.backgroundSecondary)
        .cornerRadius(NebulaTheme.CornerRadius.large)
    }
}

#Preview {
    SettingsView()
}
