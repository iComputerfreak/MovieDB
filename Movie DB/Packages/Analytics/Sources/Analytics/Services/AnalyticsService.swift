// Copyright © 2026 Jonas Frey. All rights reserved.

import OSLog
import Foundation

public final class AnalyticsService: AnalyticsTracking, @unchecked Sendable {
    public static let shared = AnalyticsService()

    private let lock = NSLock()
    private var backend: any AnalyticsBackend = NoopAnalyticsBackend()

    private init() {}

    public func configure(_ configuration: AnalyticsConfiguration) {
        let backend = PostHogAnalyticsBackend(configuration: configuration)
        lock.withLock {
            self.backend = backend
        }
    }

    public func track(_ event: AnalyticsEvent) {
        currentBackend().track(event)
    }

    public func setTrackingEnabled(_ isEnabled: Bool) {
        currentBackend().setTrackingEnabled(isEnabled)
    }

    public func isFeatureEnabled(_ flag: AnalyticsFeatureFlag) -> Bool {
        currentBackend().isFeatureEnabled(flag)
    }

    public func featureFlagPayload<T: Decodable>(_ flag: AnalyticsFeatureFlag, as type: T.Type) -> T? {
        currentBackend().featureFlagPayload(flag, as: type)
    }

    public func reloadFeatureFlags(completion: @escaping @Sendable () -> Void) {
        currentBackend().reloadFeatureFlags {
            Logger.analytics.info("Feature flags reloaded.")
            completion()
        }
    }

    private func currentBackend() -> any AnalyticsBackend {
        lock.lock()
        let backend = self.backend
        lock.unlock()
        return backend
    }
}
