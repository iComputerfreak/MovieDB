//
//  NoopAnalyticsBackend.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

final class NoopAnalyticsBackend: AnalyticsBackend {
    func track(_ event: AnalyticsEvent) {}

    func setTrackingEnabled(_ isEnabled: Bool) {}
}
