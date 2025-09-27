import SwiftUI

struct NebulaTheme {
    struct Colors {
        static let nebulaPrimary = Color(red: 0.2, green: 0.1, blue: 0.4)
        static let nebulaSecondary = Color(red: 0.4, green: 0.2, blue: 0.6)
        static let nebulaAccent = Color(red: 0.6, green: 0.4, blue: 0.8)
        static let nebulaLight = Color(red: 0.8, green: 0.7, blue: 0.9)
        static let backgroundPrimary = Color(red: 0.05, green: 0.05, blue: 0.1)
        static let backgroundSecondary = Color(red: 0.1, green: 0.1, blue: 0.15)
        static let backgroundTertiary = Color(red: 0.15, green: 0.15, blue: 0.2)
        static let textPrimary = Color.white
        static let textSecondary = Color(red: 0.8, green: 0.8, blue: 0.9)
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.7)
        static let accentBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
        static let success = Color.green
        static let warning = Color.orange
    }
    
    struct Gradients {
        static let nebulaBackground = LinearGradient(
            colors: [Colors.backgroundPrimary, Colors.backgroundSecondary, Colors.nebulaPrimary.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let nebulaAccent = LinearGradient(
            colors: [Colors.nebulaPrimary, Colors.nebulaSecondary, Colors.nebulaAccent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let sidebarBackground = LinearGradient(
            colors: [Colors.nebulaPrimary.opacity(0.9), Colors.nebulaSecondary.opacity(0.8), Colors.nebulaAccent.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let cardBackground = LinearGradient(
            colors: [Colors.backgroundTertiary.opacity(0.8), Colors.backgroundSecondary.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    struct Typography {
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 20, weight: .medium, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let small = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xl: CGFloat = 20
    }
}

struct NebulaCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NebulaTheme.Gradients.cardBackground)
            .cornerRadius(NebulaTheme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct NebulaGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    init(color: Color = NebulaTheme.Colors.nebulaAccent, radius: CGFloat = 10) {
        self.color = color
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
}

extension View {
    func nebulaCard() -> some View {
        modifier(NebulaCardModifier())
    }
    
    func nebulaGlow(color: Color = NebulaTheme.Colors.nebulaAccent, radius: CGFloat = 10) -> some View {
        modifier(NebulaGlowModifier(color: color, radius: radius))
    }
}

struct CosmicBackground: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            NebulaTheme.Gradients.nebulaBackground
                .ignoresSafeArea()
            
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...1200),
                        y: CGFloat.random(in: 0...800)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = 360
        }
    }
}
