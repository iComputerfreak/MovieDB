//
//  AppDelegate.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // MARK: - Run Migration
        let version = UserDefaults.standard.integer(forKey: JFLiterals.Keys.migrationKey)
        if version < 1 {
            print("Starting migration to version 1...")
            // Run migration to version 1
            // Fill in releaseDateOrFirstAir property for all media objects created before this version
            let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
            do {
                let results = try PersistenceController.viewContext.fetch(fetchRequest)
                for media in results {
                    if media.releaseDateOrFirstAired == nil {
                        if let movie = media as? Movie {
                            media.releaseDateOrFirstAired = movie.releaseDate
                        } else if let show = media as? Show {
                            media.releaseDateOrFirstAired = show.firstAirDate
                        } else {
                            assertionFailure("Media object is neither movie, nor show")
                        }
                    }
                }
                // Mark the migration as complete
                UserDefaults.standard.set(1, forKey: JFLiterals.Keys.migrationKey)
                print("Migration complete.")
            } catch {
                print("Error migrating database: \(error)")
            }
        }
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

