//
//  AlertHandler.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

/// Represents a utility struct that displays Alerts
struct AlertHandler {
    private init() {}

    /// Triggers an Alert on the top most view controller in the window
    /// - Parameter alert: The Alert Controller
    static func presentAlert(alert: UIAlertController) {
        if let controller = topMostViewController() {
            // UI Changes always have to be on the main thread
            Task(priority: .userInitiated) {
                await MainActor.run {
                    controller.present(alert, animated: true)
                }
            }
        }
    }
    
    /// Shows a simple alert with a title, a message and an "Ok" button
    static func showSimpleAlert(title: String?, message: String?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(.okayAction())
        presentAlert(alert: controller)
    }
    
    static func showError(title: String?, error: Error) {
        self.showSimpleAlert(
            title: title ?? Strings.Generic.alertErrorTitle,
            message: error.localizedDescription
        )
    }
    
    static func showYesNoAlert(
        title: String?,
        message: String?,
        yesAction: ((UIAlertAction) -> Void)? = nil,
        noAction: ((UIAlertAction) -> Void)? = nil
    ) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(.yesAction(yesAction))
        controller.addAction(.noAction(noAction))
        presentAlert(alert: controller)
    }
    
    // MARK: - Private functions
    
    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first { $0.isKeyWindow }
    }

    private static func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow()?.rootViewController else {
            return nil
        }
        return topMostViewController(for: rootController)
    }

    private static func topMostViewController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topMostViewController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController {
            guard let topController = navigationController.topViewController else {
                return navigationController
            }
            return topMostViewController(for: topController)
        } else if let tabController = controller as? UITabBarController {
            guard let topController = tabController.selectedViewController else {
                return tabController
            }
            return topMostViewController(for: topController)
        }
        return controller
    }
}

// Some default alert actions
extension UIAlertAction {
    /// The default "Ok" button to dismiss the alert
    static func okayAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(
            title: Strings.Generic.alertButtonOk,
            style: .default,
            handler: handler
        )
    }
    
    /// The default "Cancel" button to deny the alert
    static func cancelAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(
            title: Strings.Generic.alertButtonCancel,
            style: .cancel,
            handler: handler
        )
    }
    
    /// The default "Yes" button to confirm the alert
    static func yesAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(
            title: Strings.Generic.alertButtonYes,
            style: .default,
            handler: handler
        )
    }
    
    /// The default "No" button to deny the alert
    static func noAction(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        UIAlertAction(
            title: Strings.Generic.alertButtonNo,
            style: .cancel,
            handler: handler
        )
    }
}
