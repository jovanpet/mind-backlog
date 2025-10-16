import SwiftUI

struct ModernTheme {
    struct Color {
        // Core palette - clean whites and deep blacks
        static let pureWhite = SwiftUI.Color(hex: "FFFFFF")
        static let offWhite = SwiftUI.Color(hex: "FAFAFA")
        static let lightGray = SwiftUI.Color(hex: "F5F5F5")
        static let mediumGray = SwiftUI.Color(hex: "E8E8E8")
        static let textGray = SwiftUI.Color(hex: "6B6B6B")
        static let darkGray = SwiftUI.Color(hex: "2C2C2C")
        static let pureBlack = SwiftUI.Color(hex: "0A0A0A")
        
        // Accent colors - subtle and sophisticated
        static let accent = SwiftUI.Color(hex: "5E5CE6") // Modern purple-blue
        static let accentLight = SwiftUI.Color(hex: "8B89F7")
        static let success = SwiftUI.Color(hex: "34C759")
        static let warning = SwiftUI.Color(hex: "FF9500")
        static let error = SwiftUI.Color(hex: "FF3B30")
        
        // Dynamic colors for light/dark mode
        static let background = SwiftUI.Color("ModernBackground")
        static let surface = SwiftUI.Color("ModernSurface")
        static let textPrimary = SwiftUI.Color("ModernTextPrimary")
        static let textSecondary = SwiftUI.Color("ModernTextSecondary")
        static let divider = SwiftUI.Color("ModernDivider")
    }
    
    struct Font {
        // Modern font stack with SF Pro Display for that premium feel
        static let largeTitle = SwiftUI.Font.system(size: 34, weight: .bold, design: .default)
        static let title = SwiftUI.Font.system(size: 28, weight: .semibold, design: .default)
        static let headline = SwiftUI.Font.system(size: 22, weight: .medium, design: .default)
        static let body = SwiftUI.Font.system(size: 17, weight: .regular, design: .default)
        static let callout = SwiftUI.Font.system(size: 16, weight: .regular, design: .default)
        static let caption = SwiftUI.Font.system(size: 14, weight: .regular, design: .default)
        static let small = SwiftUI.Font.system(size: 12, weight: .regular, design: .default)
        
        // Special fonts for UI elements
        static let button = SwiftUI.Font.system(size: 17, weight: .medium, design: .default)
        static let input = SwiftUI.Font.system(size: 16, weight: .regular, design: .default)
    }
    
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
        static let round: CGFloat = 999
    }
    
    struct Shadow {
        static let subtle = (color: SwiftUI.Color.black.opacity(0.04), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: SwiftUI.Color.black.opacity(0.08), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(4))
        static let strong = (color: SwiftUI.Color.black.opacity(0.12), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(8))
        static let glow = (color: ModernTheme.Color.accent.opacity(0.3), radius: CGFloat(20), x: CGFloat(0), y: CGFloat(0))
    }
    
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let bounce = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
        static let elastic = SwiftUI.Animation.interpolatingSpring(stiffness: 200, damping: 15)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Modern View Modifiers

struct ModernCard: ViewModifier {
    var isPressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(ModernTheme.Color.pureWhite)
            .cornerRadius(ModernTheme.CornerRadius.large)
            .shadow(
                color: isPressed ? ModernTheme.Shadow.subtle.color : ModernTheme.Shadow.medium.color,
                radius: isPressed ? ModernTheme.Shadow.subtle.radius : ModernTheme.Shadow.medium.radius,
                x: 0,
                y: isPressed ? 1 : ModernTheme.Shadow.medium.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
    }
}

struct ModernButton: ViewModifier {
    var style: ButtonStyle = .primary
    var isPressed: Bool = false
    
    enum ButtonStyle {
        case primary, secondary, ghost
    }
    
    func body(content: Content) -> some View {
        content
            .font(ModernTheme.Font.button)
            .padding(.horizontal, ModernTheme.Spacing.lg)
            .padding(.vertical, ModernTheme.Spacing.md)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(ModernTheme.CornerRadius.round)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: shadowColor,
                radius: isPressed ? 2 : 8,
                x: 0,
                y: isPressed ? 1 : 4
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ModernTheme.Color.pureBlack
        case .secondary:
            return ModernTheme.Color.lightGray
        case .ghost:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return ModernTheme.Color.pureWhite
        case .secondary:
            return ModernTheme.Color.pureBlack
        case .ghost:
            return ModernTheme.Color.darkGray
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return ModernTheme.Color.pureBlack.opacity(0.2)
        case .secondary:
            return ModernTheme.Color.pureBlack.opacity(0.08)
        case .ghost:
            return Color.clear
        }
    }
}

struct ModernTextField: ViewModifier {
    @FocusState private var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .font(ModernTheme.Font.input)
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(ModernTheme.Color.lightGray)
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                            .stroke(
                                isFocused ? ModernTheme.Color.accent : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .focused($isFocused)
            .animation(ModernTheme.Animation.quick, value: isFocused)
    }
}

struct FloatingAnimation: ViewModifier {
    @State private var isAnimating = false
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -8 : 8)
            .animation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct FadeInAnimation: ViewModifier {
    @State private var isVisible = false
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(
                ModernTheme.Animation.gentle.delay(delay),
                value: isVisible
            )
            .onAppear {
                isVisible = true
            }
    }
}

// MARK: - View Extensions

extension View {
    func modernCard(isPressed: Bool = false) -> some View {
        self.modifier(ModernCard(isPressed: isPressed))
    }
    
    func modernButton(style: ModernButton.ButtonStyle = .primary, isPressed: Bool = false) -> some View {
        self.modifier(ModernButton(style: style, isPressed: isPressed))
    }
    
    func modernTextField() -> some View {
        self.modifier(ModernTextField())
    }
    
    func floatingAnimation(delay: Double = 0) -> some View {
        self.modifier(FloatingAnimation(delay: delay))
    }
    
    func fadeInAnimation(delay: Double = 0) -> some View {
        self.modifier(FadeInAnimation(delay: delay))
    }
}

// MARK: - Custom Components

struct ModernDivider: View {
    var body: some View {
        Rectangle()
            .fill(ModernTheme.Color.mediumGray)
            .frame(height: 1)
            .opacity(0.5)
    }
}

struct ModernEmptyState: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            Text(icon)
                .font(.system(size: 64))
                .floatingAnimation()
            
            VStack(spacing: ModernTheme.Spacing.sm) {
                Text(title)
                    .font(ModernTheme.Font.title)
                    .foregroundColor(ModernTheme.Color.pureBlack)
                
                Text(message)
                    .font(ModernTheme.Font.body)
                    .foregroundColor(ModernTheme.Color.textGray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(ModernTheme.Spacing.xl)
        .fadeInAnimation()
    }
}

struct GlowingBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ModernTheme.Color.accent.opacity(0.3),
                            ModernTheme.Color.accent.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 40)
                .offset(x: -100, y: -200)
                .scaleEffect(animate ? 1.2 : 0.8)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ModernTheme.Color.accentLight.opacity(0.2),
                            ModernTheme.Color.accentLight.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 350, height: 350)
                .blur(radius: 50)
                .offset(x: 100, y: 200)
                .scaleEffect(animate ? 0.9 : 1.3)
        }
        .animation(
            Animation.easeInOut(duration: 8)
                .repeatForever(autoreverses: true),
            value: animate
        )
        .onAppear {
            animate = true
        }
    }
}
