import SwiftUI

struct CompleteListView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    @State private var selectedCard: UUID? = nil
    @State private var showMenu: UUID? = nil
    @State private var searchText = ""
    
    var filteredCompleted: [ProblemItem] {
        searchText.isEmpty ? viewModel.completed : viewModel.completed.filter {
            $0.problem.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ModernTheme.Color.background
                    .ignoresSafeArea()
                
                if viewModel.completed.isEmpty {
                    // Empty state with animation
                    EmptyStateView(
                        icon: "✅",
                        title: "No Completed Issues Yet",
                        message: "Finish tasks from your active list to see them here"
                    )
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header Section
                        VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                            // Title and count
                            SectionHeader(
                                title: "Completed",
                                subtitle: "\(viewModel.completed.count) achievement\(viewModel.completed.count == 1 ? "" : "s")",
                                icon: "checkmark.circle.fill",
                                iconColor: ModernTheme.Color.success
                            )
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            
                            // Search bar
                            if viewModel.completed.count > 5 {
                                SearchBar(searchText: $searchText, placeholder: "Search completed...")
                                    .padding(.horizontal, ModernTheme.Spacing.lg)
                            }
                        }
                        .padding(.top, ModernTheme.Spacing.xl)
                        .padding(.bottom, ModernTheme.Spacing.md)
                        
                        // Cards List
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: ModernTheme.Spacing.sm) {
                                if filteredCompleted.isEmpty {
                                    // No search results
                                    VStack(spacing: ModernTheme.Spacing.md) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 48))
                                            .foregroundColor(ModernTheme.Color.textSecondary.opacity(0.5))
                                        Text("No items found")
                                            .font(ModernTheme.Font.headline)
                                            .foregroundColor(ModernTheme.Color.textSecondary)
                                        Text("Try a different search term")
                                            .font(ModernTheme.Font.caption)
                                            .foregroundColor(ModernTheme.Color.textSecondary.opacity(0.8))
                                    }
                                    .padding(.vertical, ModernTheme.Spacing.xxxl)
                                    .frame(maxWidth: .infinity)
                                } else {
                                    ForEach(Array(filteredCompleted.enumerated()), id: \.element.id) { index, item in
                                        CompletedCard(
                                            item: item,
                                            isSelected: selectedCard == item.id,
                                            showMenu: showMenu == item.id,
                                            onTap: {
                                                withAnimation(ModernTheme.Animation.spring) {
                                                    selectedCard = selectedCard == item.id ? nil : item.id
                                                }
                                            },
                                            onMenuTap: {
                                                withAnimation(ModernTheme.Animation.quick) {
                                                    showMenu = showMenu == item.id ? nil : item.id
                                                }
                                            },
                                            onReactivate: {
                                                withAnimation(ModernTheme.Animation.smooth) {
                                                    viewModel.updateProblemStatus(item.id, to: .active)
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
                            }
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .padding(.bottom, ModernTheme.Spacing.xxxl)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
            .toolbar(.visible, for: .tabBar)
        }
    }
}

// MARK: - Completed Card Component
struct CompletedCard: View {
    let item: ProblemItem
    let isSelected: Bool
    let showMenu: Bool
    let onTap: () -> Void
    let onMenuTap: () -> Void
    let onReactivate: () -> Void
    let onDelete: () -> Void

    var completionDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: item.updatedAt, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: ModernTheme.Spacing.md) {
                // Content
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                    // Completed badge
                    HStack(spacing: ModernTheme.Spacing.xs) {
                        StatusBadge(
                            icon: "checkmark.seal.fill",
                            text: "Completed",
                            color: ModernTheme.Color.success
                        )

                        Text("• \(completionDate)")
                            .font(.system(size: 10))
                            .foregroundColor(ModernTheme.Color.textSecondary)
                    }
                    .padding(.bottom, ModernTheme.Spacing.xxs)

                    // Problem title with strikethrough
                    Text(item.problem)
                        .font(ModernTheme.Font.headline)
                        .foregroundColor(ModernTheme.Color.textSecondary)
                        .strikethrough(true, color: ModernTheme.Color.textSecondary.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)

                    // Tasks preview or expanded list
                    if isSelected && !item.tasks.isEmpty {
                        TaskList(
                            tasks: item.tasks,
                            showAddButton: false,
                            isExpanded: true,
                            showNextTask: false
                        )
                        .padding(.top, ModernTheme.Spacing.sm)
                    }
                }

                Spacer()

                // Action buttons
                HStack(spacing: ModernTheme.Spacing.xs) {
                    // Menu button
                    MenuButton(isMenuOpen: showMenu, action: onMenuTap)
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(ModernTheme.Color.cardBackground.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                            .stroke(ModernTheme.Color.success.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(
                        color: ModernTheme.Color.shadow,
                        radius: isSelected ? ModernTheme.Shadow.medium.radius : ModernTheme.Shadow.small.radius,
                        x: 0,
                        y: isSelected ? ModernTheme.Shadow.medium.y : ModernTheme.Shadow.small.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .stroke(
                        isSelected ? ModernTheme.Color.success.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .onTapGesture {
                withAnimation(ModernTheme.Animation.smooth) {
                    onTap()
                }
            }

            // Context menu
            if showMenu {
                CardMenu(options: [
                    MenuOptionData(
                        icon: "arrow.uturn.backward.circle",
                        title: "Reactivate",
                        color: ModernTheme.Color.accent,
                        action: onReactivate
                    ),
                    MenuOptionData(
                        icon: "trash",
                        title: "Delete Permanently",
                        color: ModernTheme.Color.error,
                        action: onDelete,
                        showDivider: true
                    )
                ])
                .padding(.top, ModernTheme.Spacing.xs)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        CompleteListView()
            .environmentObject(ProblemItemsViewModel())
    }
}
