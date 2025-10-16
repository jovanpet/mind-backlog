//
//  ClarifyProblemView.swift
//  MindBacklog
//
//  Created by Jovan Petrovic on 10/16/25.
//

import SwiftUI

import SwiftUI

struct ClarifyProblemView: View {
    let problemTitle: String
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    @State private var navigateToNextStep = false
    @State private var navigateToBacklogAdded = false
    @State private var selectedOption: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean white background
                ModernTheme.Color.pureWhite
                    .ignoresSafeArea()
                
                // Subtle pattern background
                GeometryReader { geometry in
                    ForEach(0..<20, id: \.self) { index in
                        Circle()
                            .fill(ModernTheme.Color.lightGray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .blur(radius: 20)
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: ModernTheme.Spacing.xxl) {
                        // Animated brain emoji
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ModernTheme.Color.accent.opacity(0.1),
                                            ModernTheme.Color.accentLight.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .blur(radius: 10)
                            
                            Text("🧠")
                                .font(.system(size: 72))
                        }
                        .floatingAnimation()
                        .fadeInAnimation()
                        
                        // Problem title
                        VStack(spacing: ModernTheme.Spacing.md) {
                            Text("About:")
                                .font(ModernTheme.Font.caption)
                                .foregroundColor(ModernTheme.Color.textGray)
                                .textCase(.uppercase)
                                .tracking(1.5)
                                .fadeInAnimation(delay: 0.1)
                            
                            Text(problemTitle)
                                .font(ModernTheme.Font.title)
                                .foregroundColor(ModernTheme.Color.pureBlack)
                                .multilineTextAlignment(.center)
                                .fadeInAnimation(delay: 0.1)
                            
                            ModernDivider()
                                .frame(width: 60)
                                .fadeInAnimation(delay: 0.1)
                            
                            Text("Can you solve this\nproblem right now?")
                                .font(ModernTheme.Font.headline)
                                .foregroundColor(ModernTheme.Color.darkGray)
                                .multilineTextAlignment(.center)
                                .fadeInAnimation(delay: 0.1)
                        }
                        .padding(.horizontal, ModernTheme.Spacing.xl)
                        
                        // Option buttons with hover effects
                        VStack(spacing: ModernTheme.Spacing.md) {
                            Button(action: {
                                withAnimation(ModernTheme.Animation.spring) {
                                    selectedOption = 1
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    navigateToNextStep = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(ModernTheme.Color.success)
                                    Text("Yes, I can tackle this")
                                        .font(ModernTheme.Font.button)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(ModernTheme.Color.textGray)
                                }
                                .padding(ModernTheme.Spacing.lg)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                        .fill(selectedOption == 1 ? ModernTheme.Color.accent.opacity(0.1) : ModernTheme.Color.lightGray)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                                .stroke(selectedOption == 1 ? ModernTheme.Color.accent : Color.clear, lineWidth: 2)
                                        )
                                )
                                .foregroundColor(ModernTheme.Color.pureBlack)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(selectedOption == 1 ? 1.02 : 1.0)
                            .fadeInAnimation(delay: 0.1)
                            
                            Button(action: {
                                withAnimation(ModernTheme.Animation.spring) {
                                    selectedOption = 2
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    navigateToBacklogAdded = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(ModernTheme.Color.warning)
                                    Text("Not right now")
                                        .font(ModernTheme.Font.button)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(ModernTheme.Color.textGray)
                                }
                                .padding(ModernTheme.Spacing.lg)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                        .fill(selectedOption == 2 ? ModernTheme.Color.warning.opacity(0.1) : ModernTheme.Color.lightGray)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                                                .stroke(selectedOption == 2 ? ModernTheme.Color.warning : Color.clear, lineWidth: 2)
                                        )
                                )
                                .foregroundColor(ModernTheme.Color.pureBlack)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(selectedOption == 2 ? 1.02 : 1.0)
                            .fadeInAnimation(delay: 0.1)
                        }
                        .padding(.horizontal, ModernTheme.Spacing.xl)
                    }
                    
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, ModernTheme.Spacing.lg)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToNextStep) {
                NextStepView(problemTitle: problemTitle)
            }
            .navigationDestination(isPresented: $navigateToBacklogAdded) {
                BacklogAddedView(messageType: .cannotSolveNow, problemTitle: problemTitle)
            }
        }
    }
}
