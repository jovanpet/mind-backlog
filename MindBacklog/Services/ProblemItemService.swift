import Foundation

/// Service for persisting problem items to UserDefaults
/// Returns updated item lists for immediate UI updates
struct ProblemItemsService {
    private let storageKey = "currentProblemItems"
    let defaults = UserDefaults.standard

    func addCurrentProblemItem(_ problemItem: ProblemItem) -> [ProblemItem] {
        var items = loadCurrentProblemItems()
        items.append(problemItem)
        _ = saveCurrentProblemItems(items)
        return items
    }

    func removeCurrentProblemItem(at id: UUID) -> [ProblemItem] {
        var items = loadCurrentProblemItems()
        if let index = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: index)
            _ = saveCurrentProblemItems(items)
        }
        return items
    }

    func loadCurrentProblemItems() -> [ProblemItem] {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ProblemItem].self, from: data) {
            return decoded
        }

        return []
    }

    func saveCurrentProblemItems(_ items: [ProblemItem]) -> [ProblemItem] {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: storageKey)
        }
        return items
    }
}
