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
                
                if viewModel.completed.isEmpty {
                    // Empty state with animation
                    ModernEmptyState(
                        icon: "✅",
                        title: "No Completed Issues Yet",
                        message: "Finish tasks from your active list to see them here"
                    )
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header Section
                        VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                            // Title and count
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                                Text("Completed")
                                    .font(.system(size: 42, weight: .bold, design: .default))
                                    .foregroundColor(ModernTheme.Color.pureBlack)
                                
                                HStack(spacing: ModernTheme.Spacing.xs) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(ModernTheme.Color.success)
                                    Text("\(viewModel.completed.count) achievement\(viewModel.completed.count == 1 ? "" : "s")")
                                        .font(ModernTheme.Font.callout)
                                        .foregroundColor(ModernTheme.Color.textGray)
                                }
                            }
                            .padding(.horizontal, ModernTheme.Spacing.lg)
                            
                            // Search bar
                            if viewModel.completed.count > 5 {
                                HStack(spacing: ModernTheme.Spacing.sm) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 16))
                                        .foregroundColor(ModernTheme.Color.textGray)
                                    
                                    TextField("Search completed...", text: $searchText)
                                        .font(ModernTheme.Font.callout)
                                        .foregroundColor(ModernTheme.Color.pureBlack)
                                        .textFieldStyle(PlainTextFieldStyle())
                                    
                                    if !searchText.isEmpty {
                                        Button(action: {
                                            withAnimation(ModernTheme.Animation.quick) {
                                                searchText = ""
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(ModernTheme.Color.textGray)
                                        }
                                    }
                                }
                                .padding(ModernTheme.Spacing.sm)
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
            .navigationBarHidden(true)
            .toolbar(.visible, for: .tabBar)
        }
    }
}

// MARK: - Completed Card Component
struct CompletedCard: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    let item: ProblemItem
    let isSelected: Bool
    let showMenu: Bool
    let onTap: () -> Void
    let onMenuTap: () -> Void
    let onReactivate: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var completionDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: item.updatedAt, relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: ModernTheme.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                        // Completed badge
                        HStack(spacing: ModernTheme.Spacing.xs) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ModernTheme.Color.success)
                            
                            Text("COMPLETED")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(ModernTheme.Color.success)
                                .tracking(1.2)
                            
                            Text("• \(completionDate)")
                                .font(.system(size: 10))
                                .foregroundColor(ModernTheme.Color.textGray)
                        }
                        .padding(.bottom, ModernTheme.Spacing.xxs)
                        
                        // Problem title with strikethrough
                        Text(item.problem)
                            .font(ModernTheme.Font.headline)
                            .foregroundColor(ModernTheme.Color.textGray)
                            .strikethrough(true, color: ModernTheme.Color.textGray.opacity(0.5))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Show completed tasks if selected
                        if isSelected && !item.tasks.isEmpty {
                            VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
                                Text("Tasks completed:")
                                    .font(ModernTheme.Font.caption)
                                    .foregroundColor(ModernTheme.Color.textGray.opacity(0.8))
                                    .padding(.top, ModernTheme.Spacing.xs)
                                
                                ForEach(item.tasks) { task in
                                    HStack(spacing: ModernTheme.Spacing.xs) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(ModernTheme.Color.success.opacity(0.7))
                                        Text(task.task)
                                            .font(ModernTheme.Font.caption)
                                            .foregroundColor(ModernTheme.Color.textGray.opacity(0.8))
                                            .strikethrough(true, color: ModernTheme.Color.textGray.opacity(0.3))
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.top, ModernTheme.Spacing.sm)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        } else if !item.tasks.isEmpty {
                            Text("\(item.tasks.count) task\(item.tasks.count == 1 ? "" : "s") completed")
                                .font(ModernTheme.Font.caption)
                                .foregroundColor(ModernTheme.Color.textGray.opacity(0.7))
                                .padding(.top, ModernTheme.Spacing.xxs)
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
            }
            .padding(ModernTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .fill(ModernTheme.Color.pureWhite.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                            .stroke(ModernTheme.Color.success.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(
                        color: isPressed ? ModernTheme.Shadow.subtle.color : ModernTheme.Shadow.subtle.color,
                        radius: isPressed ? 2 : ModernTheme.Shadow.subtle.radius,
                        x: 0,
                        y: isPressed ? 1 : ModernTheme.Shadow.subtle.y
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.large)
                    .stroke(
                        isSelected ? ModernTheme.Color.success.opacity(0.3) : Color.clear,
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
                        icon: "arrow.uturn.backward.circle",
                        title: "Reactivate",
                        color: ModernTheme.Color.accent,
                        action: onReactivate
                    )
                    
                    ModernDivider()
                        .padding(.horizontal, ModernTheme.Spacing.md)
                        .padding(.vertical, ModernTheme.Spacing.xs)
                    
                    MenuOption(
                        icon: "trash",
                        title: "Delete Permanently",
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

// MARK: - Preview
#Preview {
    NavigationView {
        CompleteListView()
            .environmentObject(ProblemItemsViewModel())
    }
}
