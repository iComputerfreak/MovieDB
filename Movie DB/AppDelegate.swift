//
//  AppDelegate.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import BackgroundTasks
import CoreData
import Foundation
import StoreKit
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MARK: Prepare for UI testing
        #if DEBUG
            if CommandLine.arguments.contains("--uitesting") {
                // Prepare a fresh container to do the UI testing in
                PersistenceController.prepareForUITesting()
                JFConfig.shared.region = "DE"
                JFConfig.shared.language = "en-US"
            } else if CommandLine.arguments.contains("--screenshots") {
                // Prepare with sample data for taking screenshots
                PersistenceController.prepareForUITesting()
                JFConfig.shared.region = Locale.current.region?.identifier ?? ""
                // !!!: If the device is set to "English" (not "English (United States)"), the device region is used
                // !!!: e.g. setting the device language to "English" and the region to "Germany", yields "en_DE",
                // !!!: which is not a valid language identifier for the API.
                // !!!: So we need to make sure to only use full language identifiers (e.g. setting the device language
                // !!!: to "English (United States)" instead of "English".
                let lang = Locale.current.language.languageCode!.identifier
                let region = Locale.current.language.region!.identifier
                JFConfig.shared.language = "\(lang)_\(region)"
                
                let bgContext = PersistenceController.viewContext.newBackgroundContext()
                // Add sample data
                Task {
                    // swiftlint:disable:next force_try
                    try! await AppStoreScreenshotData(context: bgContext).prepareSampleData()
                    await MainActor.run {
                        // Commit to parent store (view context)
                        // swiftlint:disable:next force_try
                        try! bgContext.save()
                    }
                }
            }
        #endif
        
        // MARK: Register transformers
        SerializableColorTransformer.register()
        WatchProviderTransformer.register()
        EpisodeTransformer.register()
        
        // MARK: Update Poster Deny List
        loadDenyList()
        
        // MARK: Set up In App Purchases
        setupIAP()
        
        // MARK: - Delete all Cast Members from CoreData. They are not used anymore
        deleteCastMembers()
        
        // MARK: Migrations
        MigrationManager.run()
        
        // MARK: Cleanup
        Task(priority: .background) {
            try MediaLibrary.shared.cleanup()
        }
        
        // MARK: Background Fetch
        setupBackgroundFetch(application: application)
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    private func loadDenyList() {
        Task(priority: .background) {
            // Only update once per day
            let lastUpdated = UserDefaults.standard.double(forKey: JFLiterals.Keys.posterDenyListLastUpdated)
            // Convert to full seconds
            let time = Date().timeIntervalSince1970
            let diff = time - lastUpdated
            
            // Only update once every 24h
            guard diff >= 24 * 60 * 60 else {
                let durationString = (diff / Double(60 * 60)).formatted(.number.precision(.fractionLength(2)))
                print("Last deny list update was \(durationString) hours ago. Not updating deny list. (< 24h)")
                return
            }
            print("Updating deny list...")
            
            // Load the deny list
            let denyListURL = URL(string: "https://jonasfrey.de/appdata/moviedb-poster-blacklist.txt")!
            let (data, response) = try await Utils.request(from: denyListURL)
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                print("Error updating deny list. Invalid response: \(response)")
                return
            }
            
            guard let text = String(data: data, encoding: .utf8) else {
                print("Error decoding deny list:\n\(data)")
                return
            }
            
            var newDenyList: [String] = []
            let denyListLines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
            // Skip empty lines and comments
            for line in denyListLines where !line.isEmpty && !line.starts(with: "#") {
                if !line.starts(with: "/") {
                    print("Invalid line: '\(line)'. Lines must begin with a '/'. Skipping...")
                    continue
                }
                // Otherwise, we assume the line contains a poster path
                newDenyList.append(line)
            }
            
            // Update the deny list in memory
            Utils.posterDenyList = newDenyList
            // Update the timestamp
            UserDefaults.standard.set(time, forKey: JFLiterals.Keys.posterDenyListLastUpdated)
            // Save the deny list
            UserDefaults.standard.set(newDenyList, forKey: JFLiterals.Keys.posterDenyList)
        }
    }
    
    private func setupIAP() {
        // Load available products
        StoreManager.shared.getProducts(productIDs: JFLiterals.inAppPurchaseIDs)
        // Add store manager as observer for changes
        SKPaymentQueue.default().add(StoreManager.shared)
    }
    
    private func deleteCastMembers() {
        let castMembersDeletedKey = "castMembersDeleted"
        if !UserDefaults.standard.bool(forKey: castMembersDeletedKey) {
            do {
                let batchDelete = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "CastMember"))
                try PersistenceController.viewContext.execute(batchDelete)
                PersistenceController.saveContext()
                UserDefaults.standard.set(true, forKey: castMembersDeletedKey)
            } catch {
                print(error)
            }
        }
    }
    
    private func setupBackgroundFetch(application: UIApplication) {
        let taskID = "de.JonasFrey.Movie-DB.updateLibrary"
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskID,
            using: nil
        ) { task in
            // MARK: Schedule
            let request = BGAppRefreshTaskRequest(identifier: taskID)
            // Re-scheduled each time it is executed
            let timeBetweenBackgroundTasks: Double = 7 * 24 * 60 * 60 // 7 days
            request.earliestBeginDate = Date(timeIntervalSinceNow: timeBetweenBackgroundTasks)
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
            
            // MARK: Create Operation
            let operation = Task {
                do {
                    print("Updating Library from Background Fetch...")
                    let updatedCount = try await MediaLibrary.shared.update()
                    print("Updated \(updatedCount) media objects.")
                    task.setTaskCompleted(success: updatedCount > 0)
                } catch {
                    print(error)
                    task.setTaskCompleted(success: false)
                }
            }
            
            // MARK: Expiration Handler
            task.expirationHandler = {
                print("Cancelling...")
                operation.cancel()
            }
        }
    }
}
