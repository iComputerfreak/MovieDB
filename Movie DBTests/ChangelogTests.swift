// Copyright © 2026 Jonas Frey. All rights reserved.

@testable import Movie_DB
import Foundation
import Testing

@Suite("Changelog")
struct ChangelogTests {
    @Test("An unseen announcement is presented")
    func presentsUnseenAnnouncement() throws {
        let suiteName = "ChangelogTests.unseen.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        #expect(Changelog.shouldPresent(userDefaults: userDefaults))
    }

    @Test("A seen announcement is not presented again")
    func doesNotPresentSeenAnnouncement() throws {
        let suiteName = "ChangelogTests.seen.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        Changelog.markCurrentAsSeen(userDefaults: userDefaults)

        #expect(!Changelog.shouldPresent(userDefaults: userDefaults))
    }

    @Test("A different announcement identifier remains unseen")
    func presentsNewAnnouncement() throws {
        let suiteName = "ChangelogTests.new.\(UUID().uuidString)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        Changelog.markCurrentAsSeen(userDefaults: userDefaults)

        #expect(Changelog.shouldPresent(identifier: "next-feature", userDefaults: userDefaults))
    }
}
