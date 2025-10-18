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
                // Subtle gradient background
                LinearGradient(
                    colors: [
                        ModernTheme.Color.offWhite,
                        ModernTheme.Color.pureWhite
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Decorative background elements
                GeometryReader { geometry in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ModernTheme.Color.accent.opacity(0.05),
                                    ModernTheme.Color.accentLight.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                }
                .ignoresSafeArea()

                if viewModel.backlog.isEmpty {
                    ModernEmptyState(
                        icon: "📦",
                        title: "Backlog is Empty",
                        message: "Problems you can't solve yet will appear here for future reference"
                    )
                } else {
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                            // Title and count
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                                    Text("Backlog")
                                        .font(.system(size: 42, weight: .bold, design: .default))
                                        .foregroundColor(ModernTheme.Color.pureBlack)
                                    
                                    HStack(spacing: ModernTheme.Spacing.xs) {
                                        Image(systemName: "archivebox.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(ModernTheme.Color.textGray)
                                        Text("\(viewModel.backlog.count) item\(viewModel.backlog.count == 1 ? "" : "s") stored")
                                            .font(ModernTheme.Font.callout)
                                            .foregroundColor(ModernTheme.Color.textGray)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            .fadeInAnimation()
                        }
                        .padding(.top, ModernTheme.Spacing.xl)
                        .padding(.bottom, ModernTheme.Spacing.md)
                        
                        // Cards List
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: ModernTheme.Spacing.sm) {
                                if filteredAndSortedItems.isEmpty {
                                    // No search results
                                    VStack(spacing: ModernTheme.Spacing.md) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 48))
                                            .foregroundColor(ModernTheme.Color.textGray.opacity(0.5))
                                        Text("No items found")
                                            .font(ModernTheme.Font.headline)
                                            .foregroundColor(ModernTheme.Color.textGray)
                                        Text("Try a different search term")
                                            .font(ModernTheme.Font.caption)
                                            .foregroundColor(ModernTheme.Color.textGray.opacity(0.8))
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
                                                    viewModel.updateProblemStatusToActive(item.id)
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
            .navigationBarHidden(true)
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
    
    @State private var isPressed = false
    @State private var showDetails = false
    
    var daysSinceCreated: Int {
        Calendar.current.dateComponents([.day], from: item.createdAt, to: Date()).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: ModernTheme.Spacing.md) {
                // Status indicator
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ModernTheme.Color.textGray.opacity(0.3),
                                ModernTheme.Color.textGray.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .padding(.top, 8)
                
                // Content
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                    // Title with search highlighting
                    if searchText.isEmpty {
                        Text(item.problem)
                            .font(ModernTheme.Font.headline)
                            .foregroundColor(ModernTheme.Color.pureBlack)
                    } else {
                        HighlightedText(text: item.problem, searchText: searchText)
                            .font(ModernTheme.Font.headline)
                    }
                    
                    // Metadata
                    HStack(spacing: ModernTheme.Spacing.md) {
                        // Time in backlog
                        HStack(spacing: ModernTheme.Spacing.xxs) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(daysSinceCreated == 0 ? "Added today" : "\(daysSinceCreated) day\(daysSinceCreated == 1 ? "" : "s") ago")
                                .font(ModernTheme.Font.caption)
                        }
                        .foregroundColor(ModernTheme.Color.textGray)
                    }
                    
                    // Tasks preview or expanded list
                    if isSelected {
                        TaskList(for: item)
                            .padding(.top, ModernTheme.Spacing.sm)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .animation(ModernTheme.Animation.smooth, value: isSelected)
                    } else if let firstTask = item.tasks.first {
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
                
                // Action buttons
                HStack(spacing: ModernTheme.Spacing.xs) {
                    // Menu button (no quick activate)
                    Button(action: onMenuTap) {
                        Image(systemName: showMenu ? "xmark" : "ellipsis")
                            .font(.system(size: 14))
                            .foregroundColor(ModernTheme.Color.darkGray)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(showMenu ? ModernTheme.Color.lightGray : Color.clear)
                            )
                            .rotationEffect(.degrees(showMenu ? 90 : 0))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(ModernTheme.Color.pureWhite)
                    .shadow(
                        color: isPressed ? ModernTheme.Shadow.subtle.color : (isSelected ? ModernTheme.Shadow.medium.color : ModernTheme.Shadow.subtle.color),
                        radius: isPressed ? ModernTheme.Shadow.subtle.radius : (isSelected ? ModernTheme.Shadow.medium.radius : ModernTheme.Shadow.subtle.radius),
                        x: 0,
                        y: isPressed ? 1 : (isSelected ? ModernTheme.Shadow.medium.y : ModernTheme.Shadow.subtle.y)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .stroke(
                        isSelected ? ModernTheme.Color.accent.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .onTapGesture {
                withAnimation(ModernTheme.Animation.smooth) {
                    onTap()
                }
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
            
            // Context menu - vertically stacked MenuOption(s)
            if showMenu {
                VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                    MenuOption(
                        icon: "play.fill",
                        title: "Activate",
                        color: ModernTheme.Color.accent,
                        action: {
                            onMoveToActive()
                        }
                    )
                    MenuOption(
                        icon: "trash",
                        title: "Delete",
                        color: ModernTheme.Color.error,
                        action: {
                            onDelete()
                        }
                    )
                }
                .padding(.top, ModernTheme.Spacing.xs)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity),
                    removal: .scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity)
                ))
            }
        }
    }
}

// MARK: - Task List for Backlog Card
@ViewBuilder
private func TaskList(for item: ProblemItem) -> some View {
    VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
        ForEach(item.tasks) { task in
            HStack(spacing: ModernTheme.Spacing.xs) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isDone ? ModernTheme.Color.success : ModernTheme.Color.textGray)
                Text(task.task)
                    .font(ModernTheme.Font.caption)
                    .foregroundColor(ModernTheme.Color.textGray)
                    .strikethrough(task.isDone, color: .gray)
            }
        }
    }
}

// MARK: - Highlighted Text Component
struct HighlightedText: View {
    let text: String
    let searchText: String
    
    var body: some View {
        let parts = text.components(separatedBy: searchText)
        let result = parts.reduce(Text("")) { partialResult, part in
            if partialResult == Text("") {
                return Text(part)
            } else {
                return partialResult + Text(searchText)
                    .fontWeight(.semibold)
                    .foregroundColor(ModernTheme.Color.accent) + Text(part)
            }
        }
        result
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        BacklogListView()
            .environmentObject(ProblemItemsViewModel())
    }
}

