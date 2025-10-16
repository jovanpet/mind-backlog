import SwiftUI

struct ProblemItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var problem: String
    var tasks: [TaskItem]
    var status: ProblemStatus
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    
    static func == (lhs: ProblemItem, rhs: ProblemItem) -> Bool {
        return lhs.id == rhs.id
    }

    enum ProblemStatus: String, Codable {
        case backlog, active, completed
    }
}
