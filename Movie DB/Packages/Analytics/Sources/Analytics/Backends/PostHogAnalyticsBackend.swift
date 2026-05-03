// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation
import PostHog

final class PostHogAnalyticsBackend: AnalyticsBackend {
    private let configuration: AnalyticsConfiguration
    private let lock = NSLock()
    private var isTrackingEnabled: Bool

    init(configuration: AnalyticsConfiguration) {
        self.configuration = configuration
        self.isTrackingEnabled = configuration.isTrackingEnabled

        let config = PostHogConfig(
            projectToken: configuration.apiKey,
            host: configuration.host
        )
        config.captureApplicationLifecycleEvents = true
        // Screen views don't make much sense with SwiftUI, as the screens are described as
        // `UIHostingController<ModifiedContent<AnyView, RootModifier>>`, which could be anything.
        config.captureScreenViews = false
        config.preloadFeatureFlags = true
        config.personProfiles = .always
        config.sendFeatureFlagEvent = true
        config.setBeforeSend { [weak self] event in
            guard let self, self.currentTrackingEnabled() else { return nil }

            return event
        }
        PostHogSDK.shared.setup(config)

        if configuration.isTrackingEnabled {
            identifyInstallation()
        }
    }

    func track(_ event: AnalyticsEvent) {
        guard currentTrackingEnabled() else { return }

        PostHogSDK.shared.capture(event.name, properties: event.properties)
    }

    func setTrackingEnabled(_ isEnabled: Bool) {
        setTrackingEnabledState(isEnabled)

        if isEnabled {
            identifyInstallation()
            reloadFeatureFlags(completion: {})
        }
    }

    func isFeatureEnabled(_ flag: AnalyticsFeatureFlag) -> Bool {
        featureFlagResult(for: flag)?.enabled ?? false
    }

    func featureFlagPayload<T: Decodable>(_ flag: AnalyticsFeatureFlag, as type: T.Type) -> T? {
        featureFlagResult(for: flag)?.payloadAs(type)
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

    private func featureFlagResult(for flag: AnalyticsFeatureFlag) -> PostHogFeatureFlagResult? {
        PostHogSDK.shared.getFeatureFlagResult(flag.rawValue, sendFeatureFlagEvent: currentTrackingEnabled())
    }

    private func currentTrackingEnabled() -> Bool {
        lock.withLock {
            isTrackingEnabled
        }
    }

    private func setTrackingEnabledState(_ isEnabled: Bool) {
        lock.withLock {
            isTrackingEnabled = isEnabled
        }
    }
}
