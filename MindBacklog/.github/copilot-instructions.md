<!-- .github/copilot-instructions.md
Purpose: Quick actionable guide for AI coding agents working on the MindBacklog SwiftUI app.
Keep this short, concrete, and code-linked so an agent can be productive immediately.
-->

# MindBacklog — Copilot Instructions (concise)

- Project type: iOS SwiftUI single-target app. Entry point: `MindBacklogApp.swift` -> `MainTabView.swift`.
- State & domain model: `Models/ProblemItem.swift` and `Models/TaskItem.swift` (both Codable, Identifiable).

Major architecture and data flow
- UI is SwiftUI. The app-wide mutable state is held in `ViewModels/ProblemItemViewModel.swift` (an `@MainActor ObservableObject`) and injected into views with `.environmentObject` (see `MainTabView.swift`).
- Persistence is the responsibility of `Services/ProblemItemService.swift` which encodes/decodes `[ProblemItem]` with `UserDefaults` using the key `"currtenProblemItems"` (note: typo in the key). Always use service methods when updating persisted state.
- Notifications are handled by `Services/NotificationService.swift` (singleton `NotificationService.shared`) which schedules a daily 9AM notification (`identifier: "daily-9am-notification").

Project-specific conventions & patterns (do these exactly)
- Prefer modifying behavior in the view model (`ProblemItemsViewModel`) instead of directly in Views. Views call the view model (e.g., `addProblemItem`, `removeProblemItem`, `addTaskItem`).
- Persistence helpers live in `Services/ProblemItemService.swift`. When you change the stored shape or key, migrate `currtenProblemItems` carefully to avoid data loss.
- Use `@MainActor` for UI-facing services/view models — many classes are already annotated (e.g., `NotificationService`, `ProblemItemsViewModel`).
- Styling and reusable view modifiers are in `Theme/Theme.swift` and `Views/Components/` (used as `.modernTextField()`, `.modernButton()`). Follow existing modifiers rather than creating ad-hoc styles.

Important implementation details & gotchas (discoverable and actionable)
- `ProblemItemsService.removeCurrentProblemItem(at:)` force-unwraps `first(where:)` which can crash if the ID isn't present — add safe checks before removing.
- The persistence key has a typo: `currentProblemItemsKey = "currtenProblemItems"`. If you rename the key, add a migration path or preserve backwards compat.
- `ProblemItemsViewModel.addTaskItem` toggles the last task's `isDone` before appending a new task (this is intentional here—be careful when changing task behavior).
- Many views rely on `ProblemItemsViewModel.backlog/active/completed` computed properties — keep these filters intact to avoid UI regressions.

Where to make changes
- UI: `Views/` and `Views/AddProblemViews/` (use environment object and Theme modifiers).
- Business logic: `ViewModels/ProblemItemViewModel.swift`.
- Persistence and migration: `Services/ProblemItemService.swift`.
- Notifications: `Services/NotificationService.swift`.

Developer workflows (how to build, run, debug)
- Recommended: open the Xcode project and run from Xcode:
  - open `MindBacklog.xcodeproj` in Xcode and run on a simulator/device.
- Quick checks from shell: prefer Xcode UI. If you must use CLI, run builds with xcodebuild from project root, but confirm the scheme name in Xcode first (schemes may be user-specific).

Helpful file references (start here)
- Core model: `Models/ProblemItem.swift`, `Models/TaskItem.swift`
- Persistence: `Services/ProblemItemService.swift`
- View model: `ViewModels/ProblemItemViewModel.swift`
- Notifications: `Services/NotificationService.swift`
- Representative views: `Views/BacklogListView.swift`, `Views/AddProblemViews/AddProblemView.swift`, `Views/MainTabView.swift`
- Theme and components: `Theme/Theme.swift`, `Views/Components/`

If you touch persistence or public APIs
- Document the change in this file briefly (key rename, migration steps).
- Add a small unit test or a sim-run to validate migration (no test harness exists currently; run in simulator to verify user defaults behavior).

Questions for the maintainers
- Should we correct the `currtenProblemItems` typo and migrate existing saved data or preserve backward compatibility?
- Is there an authoritative CI command or scheme name you prefer for `xcodebuild` automation? If yes, add it to this doc.

If anything here is unclear, tell me which area (persistence, view model, or theme) and I will expand examples or add a migration snippet.
