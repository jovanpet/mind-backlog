import SwiftUI

/// ViewModel for managing problem items across all views
/// Handles CRUD operations and status updates for problems and tasks
@MainActor
class ProblemItemsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var items: [ProblemItem] = []

    // MARK: - Computed Properties

    var backlog: [ProblemItem] {
        items.filter { $0.status == .backlog }
    }

    var active: [ProblemItem] {
        items.filter { $0.status == .active }
    }

    var completed: [ProblemItem] {
        items.filter { $0.status == .completed }
    }

    // MARK: - Private Properties

    private let problemItemService = ProblemItemsService()

    // MARK: - Initialization

    init() {
        loadItems()
    }

    // MARK: - Public Methods

    /// Adds a new problem item to the list
    func addProblemItem(_ item: ProblemItem) {
        items = problemItemService.addCurrentProblemItem(item)
    }

    /// Adds a new task to a problem item and marks the previous task as complete
    func addTaskItem(to problemItemId: UUID, task: String) {
        guard let index = items.firstIndex(where: { $0.id == problemItemId }) else { return }

        var updatedItem = items[index]
        var updatedTasks = updatedItem.tasks

        // Mark the previous task as done
        if let lastTaskIndex = updatedTasks.indices.last {
            updatedTasks[lastTaskIndex].isDone = true
        }

        // Add new task
        updatedTasks.append(TaskItem(id: UUID(), task: task, isDone: false))
        updatedItem.tasks = updatedTasks
        updatedItem.updatedAt = Date()

        updateItemAndSave(updatedItem, at: index)
    }

    /// Removes a problem item from the list
    func removeProblemItem(_ problemItemId: UUID) {
        items = problemItemService.removeCurrentProblemItem(at: problemItemId)
    }

    /// Updates the status of a problem item
    func updateProblemStatus(_ problemItemId: UUID, to status: ProblemItem.ProblemStatus) {
        guard let index = items.firstIndex(where: { $0.id == problemItemId }) else { return }

        var updatedItem = items[index]
        updatedItem.status = status
        updatedItem.updatedAt = Date()

        // Mark all tasks as done when moving to completed
        if status == .completed {
            var updatedTasks = updatedItem.tasks
            for i in updatedTasks.indices {
                updatedTasks[i].isDone = true
            }
            updatedItem.tasks = updatedTasks
        }

        updateItemAndSave(updatedItem, at: index)
    }

    /// Refreshes items from persistent storage
    func refresh() {
        loadItems()
    }

    // MARK: - Private Methods

    /// Loads items from persistent storage
    private func loadItems() {
        items = problemItemService.loadCurrentProblemItems()
    }

    /// Updates an item at the specified index and saves to disk
    /// Creates a new array to ensure SwiftUI detects the change
    private func updateItemAndSave(_ updatedItem: ProblemItem, at index: Int) {
        var newItems = items
        newItems[index] = updatedItem
        items = newItems

        Task {
            _ = problemItemService.saveCurrentProblemItems(items)
        }
    }
}
