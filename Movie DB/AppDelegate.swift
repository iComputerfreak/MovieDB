// Copyright © 2019 Jonas Frey. All rights reserved.

#if os(iOS)
import UIKit

/// Registers iOS-specific background processing during application launch.
final class AppDelegate: NSObject, UIApplicationDelegate {
    private let backgroundHandler = BackgroundHandler()

    /// Registers background processing before launch completes.
    /// - Parameters:
    ///   - application: Current application.
    ///   - launchOptions: Options supplied by the system at launch.
    /// - Returns: `true` to continue launching.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        backgroundHandler.setupBackgroundFetch()
        return true
    }
}
#endif
