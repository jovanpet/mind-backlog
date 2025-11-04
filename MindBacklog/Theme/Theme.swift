import SwiftUI

// MARK: - Modern Theme System using Asset Catalog Colors
struct ModernTheme {
    struct Color {
        // Core colors - defined in Assets.xcassets
        static let background = SwiftUI.Color("ModernBackground")
        static let surface = SwiftUI.Color("ModernSurface")
        static let surfaceSecondary = SwiftUI.Color("ModernSurfaceSecondary")
        static let surfaceTertiary = SwiftUI.Color("ModernSurfaceTertiary")
        
        // Text colors
        static let textPrimary = SwiftUI.Color("ModernTextPrimary")
        static let textSecondary = SwiftUI.Color("ModernTextSecondary")
        static let textTertiary = SwiftUI.Color("ModernTextTertiary")
        
        // Accent colors
        static let accent = SwiftUI.Color("ModernAccent")
        static let accentSecondary = SwiftUI.Color("ModernAccentSecondary")
        static let accentTertiary = SwiftUI.Color("ModernAccentTertiary")
        
        // System colors
        static let success = SwiftUI.Color("ModernSuccess")
        static let warning = SwiftUI.Color("ModernWarning")
        static let error = SwiftUI.Color("ModernError")
        static let info = SwiftUI.Color("ModernInfo")
        
        // UI Element colors
        static let separator = SwiftUI.Color("ModernSeparator")
        static let inputBackground = SwiftUI.Color("ModernInputBackground")
        static let inputBorder = SwiftUI.Color("ModernInputBorder")
        static let cardBackground = SwiftUI.Color("ModernCardBackground")
        static let elevatedBackground = SwiftUI.Color("ModernElevatedBackground")
        
        // Shadow color (can use system shadow or custom)
        static let shadow = SwiftUI.Color.black.opacity(0.1)
        static let shadowDark = SwiftUI.Color.black.opacity(0.3)
    }
    
    struct Font {
        // Clean, modern font hierarchy
        static let largeTitle = SwiftUI.Font.system(size: 34, weight: .bold, design: .default)
        static let title = SwiftUI.Font.system(size: 28, weight: .semibold, design: .default)
        static let title2 = SwiftUI.Font.system(size: 24, weight: .semibold, design: .default)
        static let headline = SwiftUI.Font.system(size: 20, weight: .medium, design: .default)
        static let body = SwiftUI.Font.system(size: 17, weight: .regular, design: .default)
        static let callout = SwiftUI.Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = SwiftUI.Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = SwiftUI.Font.system(size: 13, weight: .regular, design: .default)
        static let caption = SwiftUI.Font.system(size: 12, weight: .regular, design: .default)
        
        // Special purpose fonts
        static let button = SwiftUI.Font.system(size: 17, weight: .medium, design: .default)
        static let buttonSmall = SwiftUI.Font.system(size: 15, weight: .medium, design: .default)
        static let input = SwiftUI.Font.system(size: 16, weight: .regular, design: .default)
        static let mono = SwiftUI.Font.system(size: 14, weight: .regular, design: .monospaced)
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
        static let xxlarge: CGFloat = 32
        static let round: CGFloat = 999
    }
    
    struct Animation {
        static let instant = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.6)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let bounce = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
        static let elastic = SwiftUI.Animation.interpolatingSpring(stiffness: 200, damping: 15)
    }
    
    struct Shadow {
        static let small = (radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let large = (radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
        static let xlarge = (radius: CGFloat(24), x: CGFloat(0), y: CGFloat(12))
        static let glow = (radius: CGFloat(20), x: CGFloat(0), y: CGFloat(0))
    }
}

// MARK: - Modern View Modifiers

struct ModernCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var isPressed: Bool = false
    var elevation: CardElevation = .medium
    
    enum CardElevation {
        case low, medium, high
        
        var shadow: (radius: CGFloat, x: CGFloat, y: CGFloat) {
            switch self {
            case .low: return ModernTheme.Shadow.small
            case .medium: return ModernTheme.Shadow.medium
            case .high: return ModernTheme.Shadow.large
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(ModernTheme.Color.cardBackground)
            .cornerRadius(ModernTheme.CornerRadius.large)
            .shadow(
                color: colorScheme == .dark ? ModernTheme.Color.shadowDark : ModernTheme.Color.shadow,
                radius: isPressed ? elevation.shadow.radius / 2 : elevation.shadow.radius,
                x: elevation.shadow.x,
                y: isPressed ? elevation.shadow.y / 2 : elevation.shadow.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(ModernTheme.Animation.quick, value: isPressed)
    }
}

struct ModernButtonModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var style: ButtonStyle = .primary
    var size: ButtonSize = .regular
    var isPressed: Bool = false
    var isFullWidth: Bool = false
    
    enum ButtonStyle {
        case primary, secondary, tertiary, ghost, destructive, success
        
        var backgroundColor: Color {
            switch self {
            case .primary: return ModernTheme.Color.accent
            case .secondary: return ModernTheme.Color.surfaceSecondary
            case .tertiary: return ModernTheme.Color.surfaceTertiary
            case .ghost: return Color.clear
            case .destructive: return ModernTheme.Color.error
            case .success: return ModernTheme.Color.success
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive, .success: return .white
            case .secondary, .tertiary: return ModernTheme.Color.textPrimary
            case .ghost: return ModernTheme.Color.accent
            }
        }
    }
    
    enum ButtonSize {
        case small, regular, large
        
        var padding: (horizontal: CGFloat, vertical: CGFloat) {
            switch self {
            case .small: return (ModernTheme.Spacing.md, ModernTheme.Spacing.sm)
            case .regular: return (ModernTheme.Spacing.lg, ModernTheme.Spacing.md)
            case .large: return (ModernTheme.Spacing.xl, ModernTheme.Spacing.lg)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return ModernTheme.Font.buttonSmall
            case .regular, .large: return ModernTheme.Font.button
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(size.font)
            .padding(.horizontal, size.padding.horizontal)
            .padding(.vertical, size.padding.vertical)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(ModernTheme.CornerRadius.round)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(ModernTheme.Animation.quick, value: isPressed)
    }
}

struct ModernTextFieldModifier: ViewModifier {
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .font(ModernTheme.Font.input)
            .padding(ModernTheme.Spacing.md)
            .background(ModernTheme.Color.inputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .stroke(
                        isFocused ? ModernTheme.Color.accent : ModernTheme.Color.inputBorder,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .cornerRadius(ModernTheme.CornerRadius.medium)
            .focused($isFocused)
            .animation(ModernTheme.Animation.quick, value: isFocused)
    }
}

// MARK: - Animation Modifiers

struct FloatingAnimationModifier: ViewModifier {
    @State private var isAnimating = false
    var delay: Double = 0
    var distance: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -distance : distance)
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

struct FadeInAnimationModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double = 0
    var duration: Double = 0.4
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(
                Animation.easeOut(duration: duration).delay(delay),
                value: isVisible
            )
            .onAppear {
                isVisible = true
            }
    }
}

struct PulseAnimationModifier: ViewModifier {
    @State private var isPulsing = false
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}


extension View {
    func modernCard(isPressed: Bool = false, elevation: ModernCardModifier.CardElevation = .medium) -> some View {
        self.modifier(ModernCardModifier(isPressed: isPressed, elevation: elevation))
    }
    
    func modernButton(
        style: ModernButtonModifier.ButtonStyle = .primary,
        size: ModernButtonModifier.ButtonSize = .regular,
        isPressed: Bool = false,
        isFullWidth: Bool = false
    ) -> some View {
        self.modifier(ModernButtonModifier(style: style, size: size, isPressed: isPressed, isFullWidth: isFullWidth))
    }
    
    func modernTextField() -> some View {
        self.modifier(ModernTextFieldModifier())
    }
    
    func floatingAnimation(delay: Double = 0, distance: CGFloat = 8) -> some View {
        self.modifier(FloatingAnimationModifier(delay: delay, distance: distance))
    }
    
    func fadeInAnimation(delay: Double = 0, duration: Double = 0.4) -> some View {
        self.modifier(FadeInAnimationModifier(delay: delay, duration: duration))
    }
    
    func pulseAnimation(delay: Double = 0) -> some View {
        self.modifier(PulseAnimationModifier(delay: delay))
    }
}


