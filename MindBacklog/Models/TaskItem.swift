import SwiftUI

struct TaskItem: Codable, Identifiable, Equatable{
    var id = UUID()
    var task: String
    var isDone: Bool
    
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        return lhs.id == rhs.id
    }
}

