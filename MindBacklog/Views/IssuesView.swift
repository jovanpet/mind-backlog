import SwiftUI

struct IssuesView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    @State private var selectedCard: UUID? = nil
    @State private var animateCards = false
    @State private var showMenu: UUID? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // Clean gradient background
                LinearGradient(
                    colors: [
                        ModernTheme.Color.pureWhite,
                        ModernTheme.Color.offWhite
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.active.isEmpty {
                    // Empty state with animation
                    ModernEmptyState(
                        icon: "🚀",
                        title: "No Active Issues",
                        message: "Add or move problems here when you're ready to take action"
                    )
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: ModernTheme.Spacing.lg) {
                            // Header section
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                                Text("Active")
                                    .font(.system(size: 42, weight: .bold, design: .default))
                                    .foregroundColor(ModernTheme.Color.pureBlack)
                                
                                HStack(spacing: ModernTheme.Spacing.xs) {
                                    Circle()
                                        .fill(ModernTheme.Color.success)
                                        .frame(width: 8, height: 8)
                                    Text("\(viewModel.active.count) item\(viewModel.active.count == 1 ? "" : "s") to tackle")
                                        .font(ModernTheme.Font.callout)
                                        .foregroundColor(ModernTheme.Color.textGray)
                                }
                            }
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .padding(.top, ModernTheme.Spacing.xl)
                            .fadeInAnimation()
                            
                            // Cards section
                            VStack(spacing: ModernTheme.Spacing.md) {
                                ForEach(Array(viewModel.active.enumerated()), id: \.element.id) { index, item in
                                    ActiveCard(
                                        item: item,
                                        isSelected: selectedCard == item.id,
                                        showMenu: showMenu == item.id,
                                        onTap: {
                                            withAnimation(ModernTheme.Animation.spring) {
                                                selectedCard = item.id
                                            }
                                        },
                                        onMenuTap: {
                                            withAnimation(ModernTheme.Animation.quick) {
                                                showMenu = showMenu == item.id ? nil : item.id
                                            }
                                        },
                                        onMoveToBacklog: {
                                            withAnimation(ModernTheme.Animation.smooth) {
                                                viewModel.updateProblemStatusToBacklog(item.id)
                                            }
                                        },
                                        onComplete: {
                                            withAnimation(ModernTheme.Animation.smooth) {
                                                viewModel.updateProblemStatusToComplete(item.id)
                                            }
                                        },
                                        onDelete: {
                                            withAnimation(ModernTheme.Animation.smooth) {
                                                viewModel.removeProblemItem(item.id)
                                            }
                                        }
                                    )
                                    .fadeInAnimation(delay: Double(index) * 0.1)
                                }
                            }
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .padding(.bottom, ModernTheme.Spacing.xl)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbar(.visible, for: .tabBar)
        }
    }
}

// MARK: - Active Card Component
struct ActiveCard: View {
    let item: ProblemItem
    let isSelected: Bool
    let showMenu: Bool
    let onTap: () -> Void
    let onMenuTap: () -> Void
    let onMoveToBacklog: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                        Text(item.problem)
                            .font(ModernTheme.Font.headline)
                            .foregroundColor(ModernTheme.Color.pureBlack)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if let firstTask = item.tasks.first {
                            HStack(spacing: ModernTheme.Spacing.xs) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(ModernTheme.Color.accent)
                                Text("Next: \(firstTask.task)")
                                    .font(ModernTheme.Font.caption)
                                    .foregroundColor(ModernTheme.Color.textGray)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Menu button
                    Button(action: onMenuTap) {
                        ZStack {
                            Circle()
                                .fill(showMenu ? ModernTheme.Color.lightGray : Color.clear)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: showMenu ? "xmark" : "ellipsis")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ModernTheme.Color.darkGray)
                                .rotationEffect(.degrees(showMenu ? 90 : 0))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Task progress indicator
                if !item.tasks.isEmpty {
                    let completedTasks = item.tasks.filter { $0.isDone }.count
                    let totalTasks = item.tasks.count
                    
                    VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                        HStack {
                            Text("\(completedTasks) of \(totalTasks) steps completed")
                                .font(ModernTheme.Font.caption)
                                .foregroundColor(ModernTheme.Color.textGray)
                            
                            Spacer()
                            
                            Text("\(Int((Double(completedTasks) / Double(totalTasks)) * 100))%")
                                .font(ModernTheme.Font.caption)
                                .fontWeight(.medium)
                                .foregroundColor(ModernTheme.Color.accent)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ModernTheme.Color.lightGray)
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [ModernTheme.Color.accent, ModernTheme.Color.accentLight],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * (Double(completedTasks) / Double(totalTasks)),
                                        height: 4
                                    )
                                    .animation(ModernTheme.Animation.spring, value: completedTasks)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(ModernTheme.Color.pureWhite)
                    .shadow(
                        color: isPressed ? ModernTheme.Shadow.subtle.color : ModernTheme.Shadow.medium.color,
                        radius: isPressed ? ModernTheme.Shadow.subtle.radius : ModernTheme.Shadow.medium.radius,
                        x: 0,
                        y: isPressed ? 2 : ModernTheme.Shadow.medium.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ? ModernTheme.Color.accent : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .onTapGesture {
                onTap()
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(ModernTheme.Animation.quick) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(ModernTheme.Animation.quick) {
                            isPressed = false
                        }
                    }
            )
            
            // Menu options
            if showMenu {
                VStack(spacing: 0) {
                    MenuOption(
                        icon: "clock.arrow.circlepath",
                        title: "Move to Backlog",
                        color: ModernTheme.Color.warning,
                        action: onMoveToBacklog
                    )
                    
                    MenuOption(
                        icon: "checkmark.circle",
                        title: "Mark as Completed",
                        color: ModernTheme.Color.success,
                        action: onComplete
                    )
                    
                    ModernDivider()
                        .padding(.horizontal, ModernTheme.Spacing.md)
                        .padding(.vertical, ModernTheme.Spacing.xs)
                    
                    MenuOption(
                        icon: "trash",
                        title: "Delete",
                        color: ModernTheme.Color.error,
                        action: onDelete
                    )
                }
                .padding(.vertical, ModernTheme.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                        .fill(ModernTheme.Color.pureWhite)
                        .shadow(
                            color: ModernTheme.Shadow.subtle.color,
                            radius: ModernTheme.Shadow.subtle.radius,
                            x: 0,
                            y: ModernTheme.Shadow.subtle.y
                        )
                )
                .padding(.top, ModernTheme.Spacing.xs)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity),
                    removal: .scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity)
                ))
            }
        }
    }
}

struct MenuOption: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ModernTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(ModernTheme.Font.callout)
                    .foregroundColor(ModernTheme.Color.darkGray)
                
                Spacer()
            }
            .padding(.horizontal, ModernTheme.Spacing.md)
            .padding(.vertical, ModernTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.small)
                    .fill(isHovered ? color.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(ModernTheme.Animation.quick) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        IssuesView()
            .environmentObject(ProblemItemsViewModel())
    }
}
