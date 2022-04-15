//
//  AppDelegate.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

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
        
        // MARK: Update Poster Blacklist
        // Only update once per day
        let lastUpdated = UserDefaults.standard.integer(forKey: JFLiterals.Keys.posterBlacklistLastUpdated)
        // Convert to full seconds
        let time = Int(Date().timeIntervalSince1970)
        let diff = time - lastUpdated
        
        // If the last update was at least 24h ago
        if diff >= 24 * 60 * 60 {
            // Load the blacklist
            let blacklistURL = "https://jonasfrey.de/appdata/moviedb-poster-blacklist.txt"
            Utils.getRequest(blacklistURL, parameters: [:]) { (data) in
                guard let data = data else {
                    print("Error fetching blacklist. Keeping current one.")
                    return
                }
                guard let text = String(data: data, encoding: .utf8) else {
                    print("Error decoding blacklist")
                    return
                }
                var newBlacklist: [String] = []
                for line in text.components(separatedBy: .newlines).map({ $0.trimmingCharacters(in: .whitespaces) }) {
                    // Skip empty lines and comments
                    if line.isEmpty || line.starts(with: "#") {
                        continue
                    }
                    if !line.starts(with: "/") {
                        print("Invalid line: '\(line)'. Skipping...")
                        continue
                    }
                    // Otherwise, we assume the line contains a poster path
                    newBlacklist.append(line)
                }
                
                // Update the blacklist
                Utils.posterBlacklist = newBlacklist
                // Update the timestamp
                UserDefaults.standard.set(time, forKey: JFLiterals.Keys.posterBlacklistLastUpdated)
                // Save the blacklist
                UserDefaults.standard.set(newBlacklist, forKey: JFLiterals.Keys.posterBlacklist)
            }
        } else {
            print("Last blacklist update was \(diff) seconds ago. Not updating blacklist. (\(diff) < \(24 * 60 * 60))")
        }
        
        // MARK: Set up In App Purchases
        // Load available products
        StoreManager.shared.getProducts(productIDs: JFLiterals.inAppPurchaseIDs)
        // Add store manager as observer for changes
        SKPaymentQueue.default().add(StoreManager.shared)
        
        
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

