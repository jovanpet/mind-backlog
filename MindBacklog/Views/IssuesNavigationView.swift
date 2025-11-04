import SwiftUI

struct IssuesNavigationView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ModernTheme.Color.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    SectionHeader(
                        title: "Issues",
                        subtitle: "Manage your problems",
                        icon: "list.bullet.circle.fill",
                        iconColor: ModernTheme.Color.accent
                    )
                    .padding(.horizontal, ModernTheme.Spacing.lg)
                    .padding(.top, ModernTheme.Spacing.xl)
                    .padding(.bottom, ModernTheme.Spacing.lg)

                    // Options List
                    VStack(spacing: ModernTheme.Spacing.md) {
                        IssueOptionCard(
                            title: "Active",
                            icon: "circle.fill",
                            iconColor: ModernTheme.Color.success,
                            count: viewModel.active.count,
                            destination: AnyView(IssuesView())
                        )

                        IssueOptionCard(
                            title: "Backlog",
                            icon: "archivebox.fill",
                            iconColor: ModernTheme.Color.textSecondary,
                            count: viewModel.backlog.count,
                            destination: AnyView(BacklogListView())
                        )

                        IssueOptionCard(
                            title: "Completed",
                            icon: "checkmark.circle.fill",
                            iconColor: ModernTheme.Color.success,
                            count: viewModel.completed.count,
                            destination: AnyView(CompleteListView())
                        )
                    }
                    .padding(.horizontal, ModernTheme.Spacing.lg)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .toolbar(.visible, for: .tabBar)
        }
    }
}

// MARK: - Issue Option Card Component
struct IssueOptionCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let count: Int
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: ModernTheme.Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.1))
                    )

                // Title
                Text(title)
                    .font(ModernTheme.Font.title)
                    .foregroundColor(ModernTheme.Color.textPrimary)

                Spacer()

                // Count Badge
                Text("\(count)")
                    .font(ModernTheme.Font.headline)
                    .foregroundColor(ModernTheme.Color.accent)
                    .padding(.horizontal, ModernTheme.Spacing.md)
                    .padding(.vertical, ModernTheme.Spacing.xs)
                    .background(
                        Capsule()
                            .fill(ModernTheme.Color.accent.opacity(0.1))
                    )

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ModernTheme.Color.textSecondary)
            }
            .padding(ModernTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ModernTheme.CornerRadius.medium)
                    .fill(ModernTheme.Color.cardBackground)
                    .shadow(
                        color: ModernTheme.Color.shadow,
                        radius: ModernTheme.Shadow.small.radius,
                        x: 0,
                        y: ModernTheme.Shadow.small.y
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    IssuesNavigationView()
        .environmentObject(ProblemItemsViewModel())
}
