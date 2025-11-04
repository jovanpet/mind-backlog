import Foundation


struct ProblemItemsService {
    private let storageKey = "currentProblemItems"
    let defaults = UserDefaults.standard

    func addCurrentProblemItem(_ problemItem: ProblemItem) {
        var items = loadCurrentProblemItems()
        items.append(problemItem)
        saveCurrentProblemItems(items)
    }

    func removeCurrentProblemItem(at id: UUID) {
        var items = loadCurrentProblemItems()
        if let index = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: index)
            saveCurrentProblemItems(items)
        }
    }

    func loadCurrentProblemItems() -> [ProblemItem] {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ProblemItem].self, from: data) {
            return decoded
        }

        return []
    }

    func saveCurrentProblemItems(_ items: [ProblemItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
}
