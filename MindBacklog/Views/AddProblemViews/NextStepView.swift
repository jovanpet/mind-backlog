import SwiftUI

struct NextStepView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    let problemTitle: String
    @State private var nextStep: String = ""
    @State private var navigateToBacklogAdded = false
    @State private var isAddButtonPressed = false
    @State private var isSkipButtonPressed = false
    @State private var showSuccess = false
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic gradient background
                LinearGradient(
                    colors: [
                        ModernTheme.Color.pureWhite,
                        ModernTheme.Color.accent.opacity(0.03)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Animated background shapes
                GeometryReader { geometry in
                    ZStack {
                        // Floating circles
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        ModernTheme.Color.success.opacity(0.15),
                                        ModernTheme.Color.success.opacity(0.02)
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 30)
                            .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                            .floatingAnimation(delay: 0.2)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        ModernTheme.Color.accent.opacity(0.1),
                                        ModernTheme.Color.accent.opacity(0.02)
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 250, height: 250)
                            .blur(radius: 40)
                            .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.7)
                            .floatingAnimation(delay: 0.5)
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: ModernTheme.Spacing.xxl) {
                        // Animated rocket with pulse effect
                        ZStack {
                            // Pulse rings
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(
                                        ModernTheme.Color.accent.opacity(0.2 - Double(index) * 0.05),
                                        lineWidth: 2
                                    )
                                    .frame(width: 100 + CGFloat(index * 30), height: 100 + CGFloat(index * 30))
                                    .scaleEffect(showSuccess ? 1.2 : 0.8)
                                    .opacity(showSuccess ? 0 : 1)
                                    .animation(
                                        Animation.easeOut(duration: 1.5)
                                            .repeatForever(autoreverses: false)
                                            .delay(Double(index) * 0.2),
                                        value: showSuccess
                                    )
                            }
                            
                            Text("🚀")
                                .font(.system(size: 72))
                                .scaleEffect(showSuccess ? 1.2 : 1.0)
                                .rotationEffect(.degrees(showSuccess ? 360 : 0))
                        }
                        .onAppear {
                            withAnimation {
                                showSuccess = true
                            }
                        }
                        
                        // Content section
                        VStack(spacing: ModernTheme.Spacing.md) {
                            // Problem context
                            VStack(spacing: ModernTheme.Spacing.xs) {
                                Text("Great! Let's tackle:")
                                    .font(ModernTheme.Font.caption)
                                    .foregroundColor(ModernTheme.Color.textGray)
                                    .textCase(.uppercase)
                                    .tracking(1.5)
                                
                                ModernDivider()
                                    .frame(width: 60)
                                
                                Text("What's your very next step?")
                                    .font(ModernTheme.Font.headline)
                                    .foregroundColor(ModernTheme.Color.darkGray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, ModernTheme.Spacing.xl)
                        }
                        
                        // Input section
                        VStack(spacing: ModernTheme.Spacing.lg) {
                            // Text field with enhanced styling
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                                HStack {
                                    TextField("", text: $nextStep, prompt: Text("E.g., \"Research for 15 minutes\" or \"Call John\"")
                                        .foregroundColor(ModernTheme.Color.textGray.opacity(0.6)))
                                        .font(ModernTheme.Font.body)
                                        .foregroundColor(ModernTheme.Color.pureBlack)
                                        .focused($isTextFieldFocused)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .submitLabel(.done)
                                        .onSubmit {
                                            if !nextStep.isEmpty {
                                                addNextStep()
                                            }
                                        }
                                }
                                .padding(ModernTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                        .fill(ModernTheme.Color.pureWhite)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                                                .stroke(
                                                    isTextFieldFocused ? ModernTheme.Color.accent : ModernTheme.Color.mediumGray,
                                                    lineWidth: isTextFieldFocused ? 2 : 1
                                                )
                                        )
                                )
                                .shadow(
                                    color: isTextFieldFocused ? ModernTheme.Color.accent.opacity(0.1) : Color.clear,
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                                
                                // Character count
                                if isTextFieldFocused && !nextStep.isEmpty {
                                    Text("\(nextStep.count) characters")
                                        .font(ModernTheme.Font.caption)
                                        .foregroundColor(ModernTheme.Color.textGray)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .fadeInAnimation(delay: 0.5)
                            
                            // Action buttons
                            VStack(spacing: ModernTheme.Spacing.sm) {
                                // Primary action button
                                Button(action: addNextStep) {
                                    HStack(spacing: ModernTheme.Spacing.sm) {
                                        Text("Add & Start")
                                            .font(ModernTheme.Font.button)
                                            .fontWeight(.semibold)
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, ModernTheme.Spacing.md)
                                    .background(
                                        LinearGradient(
                                            colors: nextStep.isEmpty ?
                                                [ModernTheme.Color.mediumGray, ModernTheme.Color.mediumGray] :
                                                [ModernTheme.Color.accent, ModernTheme.Color.accentLight],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(ModernTheme.CornerRadius.round)
                                    .shadow(
                                        color: nextStep.isEmpty ? Color.clear : ModernTheme.Color.accent.opacity(0.3),
                                        radius: 15,
                                        x: 0,
                                        y: 8
                                    )
                                    .scaleEffect(isAddButtonPressed ? 0.95 : 1.0)
                                }
                                .disabled(nextStep.isEmpty)
                                .buttonStyle(PlainButtonStyle())
                                .animation(ModernTheme.Animation.spring, value: nextStep.isEmpty)
                                .fadeInAnimation(delay: 0.6)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in isAddButtonPressed = true }
                                        .onEnded { _ in isAddButtonPressed = false }
                                )
                                
                                // Secondary action button (styled like Add & Start)
                                Button(action: {
                                    navigateToBacklogAdded = true
                                }) {
                                    HStack(spacing: ModernTheme.Spacing.sm) {
                                        Text("I'm not sure yet")
                                            .font(ModernTheme.Font.button)
                                            .fontWeight(.semibold)
                                        
                                        Image(systemName: "questionmark.circle")
                                            .font(.system(size: 18))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, ModernTheme.Spacing.md)
                                    .background(
                                        LinearGradient(
                                            colors: [ModernTheme.Color.accent, ModernTheme.Color.accentLight],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(ModernTheme.CornerRadius.round)
                                    .shadow(
                                        color: ModernTheme.Color.accent.opacity(0.3),
                                        radius: 15,
                                        x: 0,
                                        y: 8
                                    )
                                    .scaleEffect(isSkipButtonPressed ? 0.95 : 1.0)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .fadeInAnimation(delay: 0.7)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in isSkipButtonPressed = true }
                                        .onEnded { _ in isSkipButtonPressed = false }
                                )
                            }
                        }
                        .padding(.horizontal, ModernTheme.Spacing.xl)
                        
                        // Motivational hint
                        Text("💡 Keep it small and actionable")
                            .font(ModernTheme.Font.caption)
                            .foregroundColor(ModernTheme.Color.textGray)
                            .opacity(0.7)
                            .fadeInAnimation(delay: 0.8)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, keyboardHeight)
                .animation(ModernTheme.Animation.smooth, value: keyboardHeight)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToBacklogAdded) {
                BacklogAddedView(messageType: .notSure, problemTitle: problemTitle)
            }
        }
    }

    private func addNextStep() {
        guard !nextStep.isEmpty else { return }

        withAnimation(ModernTheme.Animation.spring) {
            viewModel.addProblemItem(
                ProblemItem(
                    problem: problemTitle,
                    tasks: [TaskItem(task: nextStep, isDone: false)],
                    status: ProblemItem.ProblemStatus.active,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            )
        }

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        dismiss()
    }
}

// MARK: - Preview
#Preview {
    NextStepView(problemTitle: "Learn SwiftUI")
        .environmentObject(ProblemItemsViewModel())
}
