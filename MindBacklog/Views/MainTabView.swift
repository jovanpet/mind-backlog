import SwiftUI
import UserNotifications

struct MainTabView: View {    
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
            //ReflectView()
            //    .tabItem { Label("Reflect", systemImage: "figure.wave") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ProblemItemsViewModel())
}
