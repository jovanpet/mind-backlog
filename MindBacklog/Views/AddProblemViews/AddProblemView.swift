import SwiftUI

import SwiftUI

struct AddProblemView: View {
    @State private var title = ""
    @State private var isButtonPressed = false
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color.white,
                        ModernTheme.Color.offWhite
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: ModernTheme.Spacing.xxl) {
                        // Animated emoji
                        Text("💭")
                            .font(.system(size: 80))
                            .floatingAnimation()
                        
                        // Main heading with fade in
                        VStack(spacing: ModernTheme.Spacing.sm) {
                            Text("What's on your")
                                .font(ModernTheme.Font.largeTitle)
                                .foregroundColor(ModernTheme.Color.pureBlack)
                                .fadeInAnimation(delay: 0.1)
                            
                            Text("mind?")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ModernTheme.Color.accent, ModernTheme.Color.accentLight],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .fadeInAnimation(delay: 0.2)
                        }
                        
                        // Text field with modern styling
                        VStack(spacing: ModernTheme.Spacing.lg) {
                            TextField("Type your thoughts here...", text: $title)
                                .modernTextField()
                                .focused($isTextFieldFocused)
                                .fadeInAnimation(delay: 0.3)
                            
                            // Continue button
                            NavigationLink(destination: ClarifyProblemView(problemTitle: title)) {
                                HStack(spacing: ModernTheme.Spacing.sm) {
                                    Text("Continue")
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .modernButton(style: .primary, isPressed: isButtonPressed)
                            }
                            .disabled(title.isEmpty)
                            .opacity(title.isEmpty ? 0.5 : 1.0)
                            .scaleEffect(title.isEmpty ? 0.95 : 1.0)
                            .animation(ModernTheme.Animation.spring, value: title.isEmpty)
                            .fadeInAnimation(delay: 0.4)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in isButtonPressed = true }
                                    .onEnded { _ in isButtonPressed = false }
                            )
                        }
                        .padding(.horizontal, ModernTheme.Spacing.xl)
                    }
                    
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, ModernTheme.Spacing.lg)
            }
            .navigationBarHidden(true)
            .onAppear {
                title = ""
            }
            .onDisappear {
                //title = ""
            }
        }
    }
}

#Preview {
    NavigationView {
        AddProblemView()
            .environmentObject(ProblemItemsViewModel())
    }
}

