import SwiftUI

/// Shared reusable UI components for MindBacklog
/// Contains components used across multiple views for consistency

// MARK: - Menu Option Component
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
                    .foregroundColor(ModernTheme.Color.textPrimary)

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

// MARK: - Task List Component
struct TaskList: View {
    let tasks: [TaskItem]
    var showAddButton: Bool = false
    var isExpanded: Bool = true
    var showNextTask: Bool = true
    var onAddTask: (() -> Void)? = nil

    // Computed property to find first incomplete task
    private var firstIncompleteTask: TaskItem? {
        tasks.first(where: { !$0.isDone })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
            if isExpanded {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    TaskRow(task: task)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                        .animation(ModernTheme.Animation.smooth, value: task.isDone)
                }

                if showAddButton, let onAddTask = onAddTask {
                    Button(action: onAddTask) {
                        HStack(spacing: ModernTheme.Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(ModernTheme.Color.accent)
                            Text("Add Task")
                                .font(ModernTheme.Font.caption)
                                .foregroundColor(ModernTheme.Color.accent)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, ModernTheme.Spacing.xs)
                }
            } else if showNextTask {
                // Show next incomplete task or first task
                if let nextTask = firstIncompleteTask ?? tasks.first {
                    HStack(spacing: ModernTheme.Spacing.xs) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(ModernTheme.Color.accent)
                        Text("Next: \(nextTask.task)")
                            .font(ModernTheme.Font.caption)
                            .foregroundColor(ModernTheme.Color.textSecondary)
                            .lineLimit(1)
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Task Row Component
struct TaskRow: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: ModernTheme.Spacing.xs) {
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isDone ? ModernTheme.Color.success : ModernTheme.Color.textSecondary)
                .animation(ModernTheme.Animation.smooth, value: task.isDone)

            Text(task.task)
                .font(ModernTheme.Font.caption)
                .foregroundColor(ModernTheme.Color.textSecondary)
                .strikethrough(task.isDone, color: .gray)
                .fixedSize(horizontal: false, vertical: true)
                .animation(ModernTheme.Animation.smooth, value: task.isDone)
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

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Search..."

    var body: some View {
        HStack(spacing: ModernTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(ModernTheme.Color.textSecondary)

            TextField(placeholder, text: $searchText)
                .font(ModernTheme.Font.callout)
                .foregroundColor(ModernTheme.Color.textPrimary)
                .textFieldStyle(PlainTextFieldStyle())

            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(ModernTheme.Animation.quick) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(ModernTheme.Color.textSecondary)
                }
            }
        }
        .padding(ModernTheme.Spacing.sm)
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
}

// MARK: - Menu Button Component
struct MenuButton: View {
    let isMenuOpen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isMenuOpen ? ModernTheme.Color.surfaceSecondary : Color.clear)
                    .frame(width: 44, height: 44)
                Image(systemName: isMenuOpen ? "xmark" : "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ModernTheme.Color.textPrimary)
                    .rotationEffect(.degrees(isMenuOpen ? 90 : 0))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

// MARK: - Status Badge Component
struct StatusBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: ModernTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)

            Text(text.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(color)
                .tracking(1.2)
        }
    }
}

// MARK: - Time Badge Component
struct TimeBadge: View {
    let date: Date
    var prefix: String = ""

    private var timeText: String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days == 0 {
            return "\(prefix)today"
        } else if days == 1 {
            return "\(prefix)1 day ago"
        } else {
            return "\(prefix)\(days) days ago"
        }
    }

    var body: some View {
        HStack(spacing: ModernTheme.Spacing.xxs) {
            Image(systemName: "clock")
                .font(.system(size: 11))
            Text(timeText)
                .font(ModernTheme.Font.caption)
        }
        .foregroundColor(ModernTheme.Color.textSecondary)
    }
}

// MARK: - Card Menu Component
struct CardMenu: View {
    let options: [MenuOptionData]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                if index > 0 && option.showDivider {
                    StyledDivider()
                        .padding(.horizontal, ModernTheme.Spacing.md)
                        .padding(.vertical, ModernTheme.Spacing.xs)
                }

                MenuOption(
                    icon: option.icon,
                    title: option.title,
                    color: option.color,
                    action: option.action
                )
            }
        }
        .padding(.vertical, ModernTheme.Spacing.xs)
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
        .transition(.asymmetric(
            insertion: .scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity),
            removal: .scale(scale: 0.8, anchor: .topTrailing).combined(with: .opacity)
        ))
    }
}

struct MenuOptionData {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    var showDivider: Bool = false
}

// MARK: - Section Header Component
struct SectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String?
    let iconColor: Color?

    init(title: String, subtitle: String, icon: String? = nil, iconColor: Color? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ModernTheme.Spacing.xs) {
            Text(title)
                .font(.system(size: 42, weight: .bold, design: .default))
                .foregroundColor(ModernTheme.Color.textPrimary)

            HStack(spacing: ModernTheme.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(iconColor ?? ModernTheme.Color.textSecondary)
                }
                Text(subtitle)
                    .font(ModernTheme.Font.callout)
                    .foregroundColor(ModernTheme.Color.textSecondary)
            }
        }
    }
}

// MARK: - Empty State Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: ModernTheme.Spacing.lg) {
            Text(icon)
                .font(.system(size: 64))
                .floatingAnimation()

            VStack(spacing: ModernTheme.Spacing.sm) {
                Text(title)
                    .font(ModernTheme.Font.title2)
                    .foregroundColor(ModernTheme.Color.textPrimary)

                Text(message)
                    .font(ModernTheme.Font.body)
                    .foregroundColor(ModernTheme.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .modernButton(style: .primary, size: .regular)
                }
                .padding(.top, ModernTheme.Spacing.md)
            }
        }
        .padding(ModernTheme.Spacing.xl)
        .fadeInAnimation()
    }
}

// MARK: - Divider Component
struct StyledDivider: View {
    var body: some View {
        Rectangle()
            .fill(ModernTheme.Color.separator)
            .frame(height: 1)
    }
}

// MARK: - Preview
#Preview("Menu Option") {
    VStack(spacing: ModernTheme.Spacing.md) {
        MenuOption(
            icon: "trash",
            title: "Delete",
            color: ModernTheme.Color.error,
            action: {}
        )

        MenuOption(
            icon: "checkmark.circle",
            title: "Complete",
            color: ModernTheme.Color.success,
            action: {}
        )
    }
    .padding()
}

#Preview("Search Bar") {
    SearchBar(searchText: .constant(""))
        .padding()
}

#Preview("Section Header") {
    SectionHeader(
        title: "Active",
        subtitle: "3 items to tackle",
        icon: "circle.fill",
        iconColor: ModernTheme.Color.success
    )
    .padding()
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "🚀",
        title: "No Active Issues",
        message: "Add or move problems here when you're ready to take action",
        actionTitle: "Add Problem",
        action: {}
    )
}
