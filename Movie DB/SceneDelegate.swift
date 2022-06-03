//
//  SceneDelegate.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
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
}
