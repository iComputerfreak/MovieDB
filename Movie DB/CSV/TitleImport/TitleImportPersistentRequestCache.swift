// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation
import OSLog

/// Persists successful title-import TMDB search responses in a bounded least-recently-used cache.
actor TitleImportPersistentRequestCache {
    /// Identifies one TMDB search response.
    private struct Key: Codable, Hashable {
        let query: String
        let page: Int
    }

    /// Stores one cache payload and its relative recency.
    private struct Entry: Codable {
        let key: Key
        let candidates: [TitleImportCandidate]
        var lastAccess: UInt64
    }

    /// Provides a versioned representation for durable storage.
    private struct Archive: Codable {
        let schemaVersion: Int
        let accessCounter: UInt64
        let entries: [Entry]
    }

    static let shared = TitleImportPersistentRequestCache(
        fileURL: URL.cachesDirectory
            .appendingPathComponent("TitleImport", isDirectory: true)
            .appendingPathComponent("requests.json"),
        capacity: 10_000
    )

    private static let schemaVersion = 2

    private let fileURL: URL?
    private let capacity: Int
    private var entries: [Key: Entry] = [:]
    private var accessCounter: UInt64 = 0
    private var isLoaded = false
    private var isDirty = false

    /// Creates a persistent response cache.
    /// - Parameters:
    ///   - fileURL: The archive location, or `nil` to keep values in memory only.
    ///   - capacity: The maximum search entry count.
    init(fileURL: URL?, capacity: Int = 10_000) {
        self.fileURL = fileURL
        self.capacity = max(0, capacity)
    }

    /// Returns a cached search response and marks it recently used.
    /// - Parameters:
    ///   - query: The normalized search query.
    ///   - page: The one-based result page.
    /// - Returns: Cached candidates, including a cached empty result, or `nil` on a miss.
    func search(query: String, page: Int) -> [TitleImportCandidate]? {
        loadIfNeeded()
        let key = Key(query: query, page: page)
        guard var entry = entries[key] else { return nil }
        entry.lastAccess = nextAccess()
        entries[key] = entry
        isDirty = true
        return entry.candidates
    }

    /// Stores a successful search response.
    /// - Parameters:
    ///   - candidates: The candidates returned by TMDB, including an empty successful result.
    ///   - query: The normalized search query.
    ///   - page: The one-based result page.
    func insertSearch(
        _ candidates: [TitleImportCandidate],
        query: String,
        page: Int
    ) {
        loadIfNeeded()
        let key = Key(query: query, page: page)
        entries[key] = Entry(
            key: key,
            candidates: candidates,
            lastAccess: nextAccess()
        )
        trimToCapacity()
        isDirty = true
    }

    /// Clears all cached search responses from memory and disk.
    func invalidate() {
        entries.removeAll()
        accessCounter = 0
        isLoaded = true
        isDirty = false
        guard let fileURL, FileManager.default.fileExists(atPath: fileURL.path()) else { return }
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            Logger.importExport.error("Could not invalidate title-import request cache: \(error)")
        }
    }

    /// Atomically writes changed cache data to disk without affecting import success.
    func persist() {
        loadIfNeeded()
        guard isDirty, let fileURL else { return }
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let archive = Archive(
                schemaVersion: Self.schemaVersion,
                accessCounter: accessCounter,
                entries: Array(entries.values)
            )
            try JSONEncoder().encode(archive).write(to: fileURL, options: .atomic)
            isDirty = false
        } catch {
            Logger.importExport.error("Could not persist title-import request cache: \(error)")
        }
    }

    /// Loads a compatible archive once and treats unavailable or invalid data as an empty cache.
    private func loadIfNeeded() {
        guard !isLoaded else { return }
        isLoaded = true
        guard let fileURL, FileManager.default.fileExists(atPath: fileURL.path()) else { return }
        do {
            let archive = try JSONDecoder().decode(Archive.self, from: Data(contentsOf: fileURL))
            guard archive.schemaVersion == Self.schemaVersion else {
                isDirty = true
                return
            }
            entries = Dictionary(uniqueKeysWithValues: archive.entries.map { ($0.key, $0) })
            accessCounter = archive.accessCounter
            trimToCapacity()
        } catch {
            isDirty = true
            Logger.importExport.error("Could not load title-import request cache: \(error)")
        }
    }

    /// Advances and returns the persisted access sequence.
    /// - Returns: The next monotonically increasing access value.
    private func nextAccess() -> UInt64 {
        accessCounter &+= 1
        return accessCounter
    }

    /// Removes least-recently-used entries until the configured capacity is met.
    private func trimToCapacity() {
        guard entries.count > capacity else { return }
        let removalCount = entries.count - capacity
        let keys = entries.values
            .sorted { $0.lastAccess < $1.lastAccess }
            .prefix(removalCount)
            .map(\.key)
        keys.forEach { entries.removeValue(forKey: $0) }
        isDirty = true
    }
}
