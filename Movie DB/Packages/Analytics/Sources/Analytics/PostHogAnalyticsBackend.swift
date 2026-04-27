//
//  PostHogAnalyticsBackend.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

import PostHog

final class PostHogAnalyticsBackend: AnalyticsBackend {
    init(configuration: AnalyticsConfiguration) {
        let config = PostHogConfig(apiKey: configuration.apiKey, host: configuration.host)
        config.captureApplicationLifecycleEvents = true
        config.preloadFeatureFlags = true
        config.optOut = !configuration.isTrackingEnabled
        config.personProfiles = .never
        config.sendFeatureFlagEvent = false
        PostHogSDK.shared.setup(config)
    }

    func track(_ event: AnalyticsEvent) {
        PostHogSDK.shared.capture(event.name, properties: event.properties)
    }

    func setTrackingEnabled(_ isEnabled: Bool) {
        if isEnabled {
            PostHogSDK.shared.optIn()
        } else {
            PostHogSDK.shared.optOut()
        }
    }
}
