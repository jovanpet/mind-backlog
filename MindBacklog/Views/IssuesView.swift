import SwiftUI

struct IssuesView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    @State private var selectedCard: UUID? = nil
    @State private var animateCards = false
    @State private var showMenu: UUID? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ModernTheme.Color.background
                    .ignoresSafeArea()

                if viewModel.active.isEmpty {
                    // Empty state with animation
                    EmptyStateView(
                        icon: "🚀",
                        title: "No Active Issues",
                        message: "Add or move problems here when you're ready to take action"
                    )
                } else {
                        VStack(alignment: .leading, spacing: ModernTheme.Spacing.lg) {
                            // Header section
                            SectionHeader(
                                title: "Active",
                                subtitle: "\(viewModel.active.count) item\(viewModel.active.count == 1 ? "" : "s") to tackle",
                                icon: "circle.fill",
                                iconColor: ModernTheme.Color.success
                            )
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .padding(.top, ModernTheme.Spacing.xl)
                            .fadeInAnimation()
                            
                            // Cards section
                            ScrollView(.vertical, showsIndicators: false) {

                            VStack(spacing: ModernTheme.Spacing.md) {
                                ForEach(Array(viewModel.active.enumerated()), id: \.element.id) { index, item in
                                    ActiveCard(
                                        item: item,
                                        isSelected: selectedCard == item.id,
                                        showMenu: showMenu == item.id,
                                        onTap: {
                                            withAnimation(ModernTheme.Animation.spring) {
                                                selectedCard = (selectedCard == item.id) ? nil : item.id
                                            }
                                        },
                                        onMenuTap: {
                                            withAnimation(ModernTheme.Animation.quick) {
                                                showMenu = showMenu == item.id ? nil : item.id
                                            }
                                        },
                                        onMoveToBacklog: {
                                            withAnimation(ModernTheme.Animation.smooth) {
                                                viewModel.updateProblemStatus(item.id, to: .backlog)
                                            }
                                        },
                                        onComplete: {
                                            withAnimation(ModernTheme.Animation.smooth) {
                                                viewModel.updateProblemStatus(item.id, to: .completed)
                                            }
                                        },
                                        onDelete: {
                                            withAnimation(ModernTheme.Animation.smooth) {
                                                viewModel.removeProblemItem(item.id)
                                            }
                                        }
                                    )
                                    .fadeInAnimation(delay: Double(index) * 0.05)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                                        removal: .scale(scale: 0.9).combined(with: .opacity)
                                    ))
                                }
                            }
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .padding(.bottom, ModernTheme.Spacing.xl)
                        }
                    }
                }
            }
            .toolbar(.visible, for: .tabBar)
        }
    }
}

// MARK: - Active Card Component
struct ActiveCard: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel

    let item: ProblemItem
    let isSelected: Bool
    let showMenu: Bool
    let onTap: () -> Void
    let onMenuTap: () -> Void
    let onMoveToBacklog: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    @State private var isAddingTask = false
    @State private var newTaskText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                        Text(item.problem)
                            .font(ModernTheme.Font.headline)
                            .foregroundColor(ModernTheme.Color.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        TaskList(
                            tasks: item.tasks,
                            showAddButton: isSelected,
                            isExpanded: isSelected,
                            onAddTask: {
                                withAnimation(ModernTheme.Animation.smooth) {
                                    isAddingTask = true
                                    newTaskText = ""
                                }
                            }
                        )
                        .padding(.top, ModernTheme.Spacing.sm)

                        // Add task input field
                        if isSelected && isAddingTask {
                            HStack(spacing: ModernTheme.Spacing.xs) {
                                Image(systemName: "circle")
                                    .foregroundColor(ModernTheme.Color.textSecondary)
                                TextField("New Task", text: $newTaskText, onCommit: {
                                    commitNewTask()
                                })
                                .textFieldStyle(.roundedBorder)
                                .font(ModernTheme.Font.caption)
                                Spacer()
                                Button(action: {
                                    commitNewTask()
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(ModernTheme.Color.accent)
                                        .font(.system(size: 20))
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }

                    Spacer()

                    // Menu button
                    MenuButton(isMenuOpen: showMenu, action: onMenuTap)
                }

            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(ModernTheme.Color.cardBackground)
                    .shadow(
                        color: ModernTheme.Color.shadow,
                        radius: ModernTheme.Shadow.medium.radius,
                        x: 0,
                        y: ModernTheme.Shadow.medium.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ? ModernTheme.Color.accent : Color.clear,
                        lineWidth: 2
                    )
            )
            .onTapGesture {
                onTap()
            }

            // Menu options
            if showMenu {
                CardMenu(options: [
                    MenuOptionData(
                        icon: "clock.arrow.circlepath",
                        title: "Move to Backlog",
                        color: ModernTheme.Color.warning,
                        action: onMoveToBacklog
                    ),
                    MenuOptionData(
                        icon: "checkmark.circle",
                        title: "Mark as Completed",
                        color: ModernTheme.Color.success,
                        action: onComplete
                    ),
                    MenuOptionData(
                        icon: "trash",
                        title: "Delete",
                        color: ModernTheme.Color.error,
                        action: onDelete
                    )
                ])
                .padding(.top, ModernTheme.Spacing.xs)
            }
        }
    }

    
    private func commitNewTask() {
        guard !newTaskText.trimmingCharacters(in: .whitespaces).isEmpty else {
            withAnimation(ModernTheme.Animation.smooth) {
                isAddingTask = false
            }
            return
        }
        withAnimation(ModernTheme.Animation.smooth) {
            viewModel.addTaskItem(to: item.id, task: newTaskText)
            isAddingTask = false
            newTaskText = ""
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
