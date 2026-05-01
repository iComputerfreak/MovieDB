// Copyright © 2026 Jonas Frey. All rights reserved.

protocol AnalyticsBackend: AnyObject {
    func track(_ event: AnalyticsEvent)
    func setTrackingEnabled(_ isEnabled: Bool)
    func isFeatureEnabled(_ flag: AnalyticsFeatureFlag) -> Bool
    func reloadFeatureFlags(completion: @escaping @Sendable () -> Void)
}
