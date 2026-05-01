// Copyright © 2026 Jonas Frey. All rights reserved.

final class NoopAnalyticsBackend: AnalyticsBackend {
    func track(_ event: AnalyticsEvent) {}

    func setTrackingEnabled(_ isEnabled: Bool) {}

    func isFeatureEnabled(_ flag: AnalyticsFeatureFlag) -> Bool {
        false
    }

    func reloadFeatureFlags(completion: @escaping @Sendable () -> Void) {
        completion()
    }
}
