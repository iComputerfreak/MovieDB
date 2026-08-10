// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

/// Tracks the progress of in-progress library updates/reloads (`MediaLibrary.update()` /
/// `MediaLibrary.reloadAll(fromBackground:origin:)`), so the UI can display live progress
/// while the app is active.
///
/// Multiple updates can run concurrently (e.g. an app-launch reload still running when the user
/// manually triggers a Settings update), so progress is tracked per-invocation in a dictionary
/// keyed by a `UUID`, instead of a single shared counter that different callers would clobber.
///
/// This type is `@MainActor`-isolated, so it is safe to mutate from the unstructured `TaskGroup`
/// child tasks in `MediaLibrary` (which run on arbitrary executors): every mutating call is
/// `await`ed by the caller, which serializes it onto the main actor.
@Observable
@MainActor
final class LibraryUpdateStatus {
    static let shared = LibraryUpdateStatus()

    private init() {}

    enum Origin {
        /// Settings "Update" button -> `MediaLibrary.update()`
        case manualUpdate
        /// Settings "Reload" button, or a language/region change -> `MediaLibrary.reloadAll()`
        case manualReload
        /// Throttled reload performed shortly after app launch
        case appLaunch
        /// `BGTaskScheduler` background refresh task
        case backgroundRefresh
        /// One-time library reload performed by a migration
        case migration
    }

    struct Entry: Identifiable {
        let id = UUID()
        let origin: Origin
        let startedAt = Date.now
        var current = 0
        var total: Int

        var percentage: Double {
            guard total > 0 else { return 0 }
            return Double(current) / Double(total)
        }
    }

    private(set) var entries: [UUID: Entry] = [:]

    var isActive: Bool { !entries.isEmpty }

    /// Starts tracking a new update with the given number of items to process.
    /// - Returns: An identifier to pass to `increment(_:)`/`finish(_:)`, or `nil` if `total` is `0`
    ///   (nothing to report progress for, so nothing is tracked).
    @discardableResult
    func begin(origin: Origin, total: Int) -> UUID? {
        guard total > 0 else { return nil }
        let entry = Entry(origin: origin, total: total)
        entries[entry.id] = entry
        return entry.id
    }

    /// Marks that one more item has been processed for the update identified by `id`.
    /// No-op if `id` is `nil` or the update has already finished.
    func increment(_ id: UUID?) {
        guard let id else { return }
        entries[id]?.current += 1
    }

    /// Marks the update identified by `id` as finished and stops tracking it.
    /// No-op if `id` is `nil`.
    func finish(_ id: UUID?) {
        guard let id else { return }
        entries.removeValue(forKey: id)
    }
}
