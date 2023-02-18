//
//  SceneDelegate.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("Scene entered background.")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        PersistenceController.saveContext()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the app is terminated
        PersistenceController.saveContext()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // MARK: App Store Rating
        // Ask for a rating, if it has been at least 7 days since the user first opened the app
        // and ask only once
        Task(priority: .background) {
            let userDefs = UserDefaults.standard
            if userDefs.integer(forKey: JFLiterals.Keys.askedForAppRating) == 0 {
                guard let date = userDefs.object(forKey: JFLiterals.Keys.firstAppOpenDate) as? Date else {
                    // First time opening the app, save the date and return
                    userDefs.set(Date.now, forKey: JFLiterals.Keys.firstAppOpenDate)
                    return
                }
                if abs(Date.now.distance(to: date)) > 7 * .day {
                    // Never asked and at least 7 days since first opening the app
                    if let scene = scene as? UIWindowScene {
                        print("Asking the user for an app store rating")
                        SKStoreReviewController.requestReview(in: scene)
                        // Store as integer instead of bool, since we can technically ask multiple times
                        userDefs.set(1, forKey: JFLiterals.Keys.askedForAppRating)
                    }
                }
            }
        }
    }
}
