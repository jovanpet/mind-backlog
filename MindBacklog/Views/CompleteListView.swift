import SwiftUI

struct CompleteListView: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel

    var body: some View {
        NavigationStack {
            
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [ModernTheme.Color.pureWhite, ModernTheme.Color.offWhite]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if viewModel.active.isEmpty {
                    // Empty state with animation
                    ModernEmptyState(
                        icon: "✅",
                        title: "No Completed Issues",
                        message: "Complete Active problems to see them here"
                    )
                }else{
                    
                }
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

private struct CompletedCard: View {
    @EnvironmentObject var viewModel: ProblemItemsViewModel
    let item: ProblemItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.problem)
                .strikethrough(true)
                .foregroundColor(ModernTheme.Color.textGray)
                .font(ModernTheme.Font.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .background(ModernTheme.Color.pureWhite)
        .cornerRadius(16)
        .overlay(menuOverlay)
        .fadeInAnimation()
    }

    private var menuOverlay: some View {
        HStack(spacing: 12) {
            Spacer()
            Menu {
                Button("Move to Active") {
                    withAnimation {
                        viewModel.updateProblemStatusToActive(item.id)
                    }
                }
                Button("Delete", role: .destructive) {
                    withAnimation {
                        viewModel.removeProblemItem(item.id)
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(ModernTheme.Color.textGray)
                    .padding(16)
            }
        }
        .padding(.trailing, 12)
    }
}

struct CompleteListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CompleteListView()
                .environmentObject(ProblemItemsViewModel())
        }
    }
}
