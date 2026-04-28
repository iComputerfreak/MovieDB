//
//  NoopAnalyticsBackend.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

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
