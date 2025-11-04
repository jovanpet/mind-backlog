import SwiftUI

struct BacklogAddedView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    @Environment(\.dismiss) private var dismiss
    
    enum MessageType {
        case added
        case cannotSolveNow
        case notSure
    }
    
    let messageType: MessageType
    let problemTitle: String
    
    @State private var showConfetti = false
    @State private var cardScale = 0.8
    @State private var cardOpacity = 0.0
    @State private var buttonPressed = false
    @State private var emojiScale = 1.0
    
    private var emoji: String {
        switch messageType {
        case .added: return "✅"
        case .cannotSolveNow: return "😌"
        case .notSure: return "💭"
        }
    }
    
    private var title: String {
        switch messageType {
        case .added: return "Let's Get Started"
        case .cannotSolveNow: return "Perfectly Fine"
        case .notSure: return "No Worries"
        }
    }
    
    private var subtitle: String {
        switch messageType {
        case .added: return "Start by completing the first task"
        case .cannotSolveNow: return "It's safely stored in your backlog"
        case .notSure: return "We'll keep it warm for you"
        }
    }
    
    private var motivationalQuotes: [String] {
        switch messageType {
        case .added:
            return [
                "The most important thing is to start",
                "Small steps lead to big results",
                "Don't be afraid to take the first step",
                "The journey begins with the first step"
            ]
        case .cannotSolveNow:
            return [
                "Progress isn't always linear",
                "Rest is part of the journey",
                "Tomorrow is another opportunity",
                "Every pause has its purpose"
            ]
        case .notSure:
            return [
                "Clarity comes with time",
                "The best ideas need to marinate",
                "Uncertainty is the birthplace of possibility",
                "Great things take time to unfold"
            ]
        }
    }
    
    var body: some View {
        ZStack {
            //Bakgrounf
            ModernTheme.Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main content card
                VStack(spacing: ModernTheme.Spacing.xl) {
                    // Emoji with background
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors:[
                                        ModernTheme.Color.accent.opacity(0.4),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 160, height: 160)
                            .blur(radius: 20)
                            .scaleEffect(showConfetti ? 1.3 : 1.0)
                        
                        // Emoji container
                        ZStack {
                            Circle()
                                .fill(ModernTheme.Color.elevatedBackground)
                                .frame(width: 100, height: 100)
                                .shadow(
                                    color: ModernTheme.Color.shadow,
                                    radius: ModernTheme.Shadow.medium.radius,
                                    x: 0,
                                    y: ModernTheme.Shadow.medium.y
                                )
                            
                            Text(emoji)
                                .font(.system(size: 56))
                                .scaleEffect(emojiScale)
                        }
                    }
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    
                    // Text content
                    VStack(spacing: ModernTheme.Spacing.md) {
                        Text(title)
                            .font(.system(size: 36, weight: .bold, design: .default))
                            .foregroundColor(ModernTheme.Color.textPrimary)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                        
                        Text(subtitle)
                            .font(ModernTheme.Font.body)
                            .foregroundColor(ModernTheme.Color.textSecondary)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                            .animation(
                                ModernTheme.Animation.gentle.delay(0.1),
                                value: cardOpacity
                            )
                    }
                    
                    // Problem title card
                    VStack(spacing: ModernTheme.Spacing.sm) {
                        HStack(spacing: ModernTheme.Spacing.xs) {
                            Image(systemName: "archivebox.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ModernTheme.Color.accent)
                            
                            Text("SAVED TO BACKLOG")
                                .font(ModernTheme.Font.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(ModernTheme.Color.textSecondary)
                                .tracking(1.5)
                        }
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                        .animation(
                            ModernTheme.Animation.gentle.delay(0.2),
                            value: cardOpacity
                        )
                        
                        Text(problemTitle)
                            .font(ModernTheme.Font.headline)
                            .foregroundColor(ModernTheme.Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .padding(.vertical, ModernTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                    .fill(ModernTheme.Color.surfaceSecondary.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                            .stroke(ModernTheme.Color.surface.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                            .animation(
                                ModernTheme.Animation.gentle.delay(0.3),
                                value: cardOpacity
                            )
                    }
                    
                    // Motivational quote section removed
                }
                .padding(.horizontal, ModernTheme.Spacing.xl)
                
                Spacer()
                Spacer()
                
                // Bottom action section
                VStack(spacing: ModernTheme.Spacing.lg) {
                    // Stats row
                    HStack(spacing: ModernTheme.Spacing.xl) {
                        
                        StatItem(
                            icon: "flame",
                            value: "\(viewModel.active.count)",
                            label: "Active"
                        )
                        
                        StatItem(
                            icon: "archivebox",
                            value: "\(viewModel.backlog.count + 1)",
                            label: "In Backlog"
                        )
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                        .animation(
                            ModernTheme.Animation.gentle.delay(0.5),
                            value: cardOpacity
                        )
                        
                        StatItem(
                            icon: "checkmark.circle",
                            value: "\(viewModel.completed.count)",
                            label: "Completed"
                        )
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                        .animation(
                            ModernTheme.Animation.gentle.delay(0.6),
                            value: cardOpacity
                        )

                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                        .animation(
                            ModernTheme.Animation.gentle.delay(0.7),
                            value: cardOpacity
                        )
                    }
                    
                    // Continue button
                    Button(action: {
                        saveAndDismiss()
                    }) {
                        HStack(spacing: ModernTheme.Spacing.sm) {
                            Text("Continue")
                                .font(ModernTheme.Font.button)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(ModernTheme.Color.inputBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ModernTheme.Spacing.md)
                        .background(
                            ModernTheme.Color.accent
                        )
                        .cornerRadius(ModernTheme.CornerRadius.round)
                        .shadow(
                            color: ModernTheme.Color.textPrimary.opacity(0.2),
                            radius: buttonPressed ? 5 : 15,
                            x: 0,
                            y: buttonPressed ? 2 : 8
                        )
                        .scaleEffect(buttonPressed ? 0.95 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, ModernTheme.Spacing.xl)
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .animation(
                        ModernTheme.Animation.gentle.delay(0.8),
                        value: cardOpacity
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation(ModernTheme.Animation.quick) {
                                    buttonPressed = true
                                }
                            }
                            .onEnded { _ in
                                withAnimation(ModernTheme.Animation.quick) {
                                    buttonPressed = false
                                }
                            }
                    )
                }
                .padding(.bottom, ModernTheme.Spacing.xl)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(ModernTheme.Animation.bounce) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
            withAnimation(ModernTheme.Animation.gentle.delay(0.3)) {
                showConfetti = true
            }
            withAnimation(
                Animation.easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                emojiScale = 1.1
            }
        }
    }
    
    private func saveAndDismiss() {
        viewModel.addProblemItem(
            ProblemItem(
                problem: problemTitle,
                tasks: [],
                status: ProblemItem.ProblemStatus.backlog,
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
}

// MARK: - Particle View
struct ParticleView: View {
    let color: Color
    let delay: Double
    @State private var offset = CGSize.zero
    @State private var opacity = 1.0
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: CGFloat.random(in: 4...12), height: CGFloat.random(in: 4...12))
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: Double.random(in: 2...4))
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -200 ... 200),
                        height: CGFloat.random(in: -400 ... -100)
                    )
                    opacity = 0
                }
            }
            .position(
                x: UIScreen.main.bounds.width / 2 + CGFloat.random(in: -50...50),
                y: UIScreen.main.bounds.height / 2
            )
    }
}

// MARK: - Stat Item Component
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: ModernTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(ModernTheme.Color.accent)
            
            Text(value)
                .font(ModernTheme.Font.headline)
                .foregroundColor(ModernTheme.Color.textPrimary)
            
            Text(label)
                .font(ModernTheme.Font.caption)
                .foregroundColor(ModernTheme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ModernTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.small)
                .fill(ModernTheme.Color.surfaceSecondary.opacity(0.5))
        )
    }
}

// MARK: - Preview
struct BacklogAddedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BacklogAddedView(messageType: .notSure, problemTitle: "Write my graduation thesis")
                .environmentObject(ProblemItemsViewModel())
        }
    }
}
