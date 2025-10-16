import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel = ProblemItemsViewModel()
    
    var body: some View {
        TabView {
            AddProblemView()
                .tabItem { Label("Add", systemImage: "plus.circle") }
            IssuesView()
                .tabItem { Label("Active", systemImage: "list.bullet") }
            BacklogListView()
                .tabItem { Label("Backlog", systemImage: "clock") }
            CompleteListView()
                .tabItem { Label("Completed", systemImage: "checkmark.circle") }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    MainTabView()
        .environmentObject(ProblemItemsViewModel())
}
