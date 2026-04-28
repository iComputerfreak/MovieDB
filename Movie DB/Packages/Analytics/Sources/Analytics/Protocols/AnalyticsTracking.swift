//
//  AnalyticsTracking.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

public protocol AnalyticsTracking: AnyObject {
    func track(_ event: AnalyticsEvent)
    func setTrackingEnabled(_ isEnabled: Bool)
    func isFeatureEnabled(_ flag: AnalyticsFeatureFlag) -> Bool
    func reloadFeatureFlags(completion: @escaping @Sendable () -> Void)
}
