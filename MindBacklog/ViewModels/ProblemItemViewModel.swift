import SwiftUI

@MainActor
class ProblemItemsViewModel: ObservableObject {
    @Published var items: [ProblemItem] = []
    
    var backlog: [ProblemItem] { items.filter { $0.status == ProblemItem.ProblemStatus.backlog } }
    var active: [ProblemItem] { items.filter { $0.status == ProblemItem.ProblemStatus.active } }
    var completed: [ProblemItem] { items.filter { $0.status == ProblemItem.ProblemStatus.completed } }
    
    private let problemItemService = ProblemItemsService()
    
    func loadItems() {
        items = problemItemService.loadCurrentProblemItems()
    }
    
    init() {
        loadItems()
    }
    
    func addProblemItem(_ item: ProblemItem) {
        problemItemService.addCurrentProblemItem(item)
        refresh()
    }
    
    func addTaskItem(to problemItemId: UUID, task: String) {
        guard let index = items.firstIndex(where: { $0.id == problemItemId }) else { return }
        
        let newTask = TaskItem(id: UUID(), task: task, isDone: false)
        items[index].tasks.append(newTask)
        toggleLastTaskDone(for: problemItemId)
        
        problemItemService.saveCurrentProblemItems(items)
    }
    
    func toggleLastTaskDone(for problemItemId: UUID) {
        guard let problemIndex = items.firstIndex(where: { $0.id == problemItemId }) else { return }
        guard let taskIndex = items[problemIndex].tasks.indices.last else { return }
        
        items[problemIndex].tasks[taskIndex].isDone.toggle()
    }
    
    func removeProblemItem(_ problemItemId: UUID) {
        problemItemService.removeCurrentProblemItem(at: problemItemId)
        refresh()
    }

    func updateProblemStatusToComplete(_ problemItemId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == problemItemId }) else { return }
        items[index].status = ProblemItem.ProblemStatus.completed
        items[index].updatedAt = Date()
        problemItemService.saveCurrentProblemItems(items)
    }
    
    func updateProblemStatusToBacklog(_ problemItemId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == problemItemId }) else { return }
        items[index].status = ProblemItem.ProblemStatus.backlog
        items[index].updatedAt = Date()
        problemItemService.saveCurrentProblemItems(items)
    }
    
    func updateProblemStatusToActive(_ problemItemId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == problemItemId }) else { return }
        items[index].status = ProblemItem.ProblemStatus.active
        items[index].updatedAt = Date()
        problemItemService.saveCurrentProblemItems(items)
    }
    
    func refresh() {
        loadItems()
    }
    
}
