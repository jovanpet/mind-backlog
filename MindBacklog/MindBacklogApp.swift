import SwiftUI
import UserNotifications

@main
struct MindBacklogApp: App {
    @StateObject private var notificationManager = NotificationService.shared
    @StateObject var viewModel = ProblemItemsViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task {
                    await notificationManager.requestAuthorization()
                    notificationManager.scheduleNotification(
                        title: "🧠 MindBacklog Reminder",
                        body: "Take a minute to reflect on your mind — check your backlog or add a new thought."
                    )
                }
                .environmentObject(viewModel)
        }
    }
}
