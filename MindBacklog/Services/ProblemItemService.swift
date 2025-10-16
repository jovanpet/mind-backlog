import Foundation


struct ProblemItemsService {
    private let currentProblemItemsKey = "currtenProblemItems"
    let defaults = UserDefaults.standard
    
    func addCurrentProblemItem(_ problemItem: ProblemItem) {
        var items: [ProblemItem] = []
        if let data = defaults.data(forKey: currentProblemItemsKey),
           let decoded = try? JSONDecoder().decode([ProblemItem].self, from: data) {
            items = decoded
        }
        
        items.append(problemItem)
        
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: currentProblemItemsKey)
        }
    }
    
    func removeCurrentProblemItem(at id: UUID) {
        var items: [ProblemItem] = []
        if let data = defaults.data(forKey: currentProblemItemsKey),
           let decoded = try? JSONDecoder().decode([ProblemItem].self, from: data) {
            items = decoded
        }
        
        if let index = items.firstIndex(of: items.first(where: { $0.id == id })!) {
            items.remove(at: index)
        }
        
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: currentProblemItemsKey)
        }
    }
    
    func loadCurrentProblemItems() -> [ProblemItem] {
        var items: [ProblemItem] = []
        if let data = defaults.data(forKey: currentProblemItemsKey),
           let decoded = try? JSONDecoder().decode([ProblemItem].self, from: data) {
            items = decoded
        }
        return items
    }
    
    func saveCurrentProblemItems(_ items: [ProblemItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: currentProblemItemsKey)
        }
    }
}
