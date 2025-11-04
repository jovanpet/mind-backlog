import SwiftUI

struct TaskItem: Codable, Identifiable, Equatable {
    var id = UUID()
    var task: String
    var isDone: Bool
}

