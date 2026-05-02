// Copyright © 2026 Jonas Frey. All rights reserved.

import PostHog

final class PostHogAnalyticsBackend: AnalyticsBackend {
    private let configuration: AnalyticsConfiguration

    init(configuration: AnalyticsConfiguration) {
        self.configuration = configuration

        let config = PostHogConfig(
            projectToken: configuration.apiKey,
            host: configuration.host
        )
        config.captureApplicationLifecycleEvents = true
        // Screen views don't make much sense with SwiftUI, as the screens are described as
        // `UIHostingController<ModifiedContent<AnyView, RootModifier>>`, which could be anything.
        config.captureScreenViews = false
        config.preloadFeatureFlags = true
        config.optOut = !configuration.isTrackingEnabled
        config.personProfiles = .always
        config.sendFeatureFlagEvent = true
        PostHogSDK.shared.setup(config)

        if configuration.isTrackingEnabled {
            identifyInstallation()
        }
    }

    func track(_ event: AnalyticsEvent) {
        PostHogSDK.shared.capture(event.name, properties: event.properties)
    }

    func setTrackingEnabled(_ isEnabled: Bool) {
        if isEnabled {
            PostHogSDK.shared.optIn()
            identifyInstallation()
        } else {
            PostHogSDK.shared.optOut()
        }
    }

    func isFeatureEnabled(_ flag: AnalyticsFeatureFlag) -> Bool {
        PostHogSDK.shared.isFeatureEnabled(flag.rawValue)
    }

    func reloadFeatureFlags(completion: @escaping @Sendable () -> Void) {
        PostHogSDK.shared.reloadFeatureFlags {
            completion()
        }
    }

    private func identifyInstallation() {
        PostHogSDK.shared.identify(
            configuration.distinctID,
            userProperties: configuration.personProperties,
            userPropertiesSetOnce: configuration.personPropertiesSetOnce
        )
    }
}
