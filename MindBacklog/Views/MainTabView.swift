import SwiftUI
import UserNotifications

struct MainTabView: View {
    var body: some View {
        TabView {
            AddProblemView()
                .tabItem { Label("Add", systemImage: "plus.circle") }
            IssuesNavigationView()
                .tabItem { Label("Issues", systemImage: "list.bullet") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ProblemItemsViewModel())
}
