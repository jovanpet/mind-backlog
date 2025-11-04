import SwiftUI

import SwiftUI

struct BacklogListView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    @State private var selectedCard: UUID? = nil
    @State private var showMenu: UUID? = nil
    @State private var draggedItem: ProblemItem? = nil
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newest
    
    enum SortOption: String, CaseIterable {
        case newest = "Newest First"
        case oldest = "Oldest First"
        case alphabetical = "A to Z"
        
        var icon: String {
            switch self {
            case .newest: return "arrow.down.circle"
            case .oldest: return "arrow.up.circle"
            case .alphabetical: return "textformat"
            }
        }
    }
    
    var filteredAndSortedItems: [ProblemItem] {
        let filtered = searchText.isEmpty ? viewModel.backlog : viewModel.backlog.filter {
            $0.problem.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .newest:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .oldest:
            return filtered.sorted { $0.createdAt < $1.createdAt }
        case .alphabetical:
            return filtered.sorted { $0.problem < $1.problem }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ModernTheme.Color.background
                    .ignoresSafeArea()
                if viewModel.backlog.isEmpty {
                    EmptyStateView(
                        icon: "📦",
                        title: "Backlog is Empty",
                        message: "Problems you can't solve yet will appear here for future reference"
                    )
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header Section
                        VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                            // Title and count
                            SectionHeader(
                                title: "Backlog",
                                subtitle: "\(viewModel.backlog.count) item\(viewModel.backlog.count == 1 ? "" : "s") stored",
                                icon: "archivebox.fill",
                                iconColor: ModernTheme.Color.textSecondary
                            )
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .fadeInAnimation()
                        }
                        .padding(.top, ModernTheme.Spacing.xl)
                        .padding(.bottom, ModernTheme.Spacing.md)
                        
                        // Cards List
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: ModernTheme.Spacing.sm) {
                                if filteredAndSortedItems.isEmpty {
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
                                    ForEach(Array(filteredAndSortedItems.enumerated()), id: \.element.id) { index, item in
                                        BacklogCard(
                                            item: item,
                                            isSelected: selectedCard == item.id,
                                            showMenu: showMenu == item.id,
                                            searchText: searchText,
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
                                            onMoveToActive: {
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
                }
            }
            .toolbar(.visible, for: .tabBar)
        }
    }
}

// MARK: - Backlog Card Component
struct BacklogCard: View {
    let item: ProblemItem
    let isSelected: Bool
    let showMenu: Bool
    let searchText: String
    let onTap: () -> Void
    let onMenuTap: () -> Void
    let onMoveToActive: () -> Void
    let onDelete: () -> Void
    
    @State private var showDetails = false
    
    var daysSinceCreated: Int {
        Calendar.current.dateComponents([.day], from: item.createdAt, to: Date()).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: ModernTheme.Spacing.md) {                
                // Content
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                    // Title with search highlighting
                    if searchText.isEmpty {
                        Text(item.problem)
                            .font(ModernTheme.Font.headline)
                            .foregroundColor(ModernTheme.Color.textPrimary)
                    } else {
                        HighlightedText(text: item.problem, searchText: searchText)
                            .font(ModernTheme.Font.headline)
                    }
                    
                    // Metadata
                    TimeBadge(date: item.createdAt, prefix: "Added ")
                    
                    // Tasks preview or expanded list
                    TaskList(tasks: item.tasks, isExpanded: isSelected)
                        .padding(.top, ModernTheme.Spacing.sm)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: ModernTheme.Spacing.xs) {
                    // Menu button (no quick activate)
                    MenuButton(isMenuOpen: showMenu, action: onMenuTap)
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(ModernTheme.Color.cardBackground)
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
                        isSelected ? ModernTheme.Color.accent.opacity(0.3) : Color.clear,
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
                        icon: "play.fill",
                        title: "Activate",
                        color: ModernTheme.Color.accent,
                        action: onMoveToActive
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
}



// MARK: - Preview
#Preview {
    NavigationView {
        BacklogListView()
            .environmentObject(ProblemItemsViewModel())
    }
}

