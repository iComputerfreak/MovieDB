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
import os.log
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
                // Make sure the app does not ask for a rating during UI testing
                UserDefaults.standard.set(1, forKey: JFLiterals.Keys.askedForAppRating)
            } else if CommandLine.arguments.contains("--screenshots") {
                // Make sure the app does not ask for a rating during UI testing
                UserDefaults.standard.set(1, forKey: JFLiterals.Keys.askedForAppRating)
                // Prepare with sample data for taking screenshots
                PersistenceController.prepareForUITesting()
                JFConfig.shared.region = Locale.current.region?.identifier ?? ""
                // Combining language and region can lead to invalid language/region pairs (e.g. if the device language
                // is "English" and the device region is "Germany", the pair will be "en-DE", on the other hand, if the
                // device language is "English (Australia)" and the region is "Germany", the pair will correctly be
                // "en-AU".
                let lang = Locale.current.language.languageCode!.identifier
                let region = Locale.current.language.region!.identifier
                JFConfig.shared.language = "\(lang)-\(region)"
                
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
        EpisodeTransformer.register()
        
        // MARK: Update Poster Deny List
        loadDenyList()
        
        // MARK: Run Migrations
        let migrationManager = MigrationManager()
        
        migrationManager.register(DeleteOldPosterFilesMigration.self)
        migrationManager.register(ReloadWatchProvidersMigration.self)
        
        migrationManager.run()
        
        // MARK: Set up In App Purchases
        setupIAP()
        
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
                Logger.network.info(
                    // swiftlint:disable:next line_length
                    "Last deny list update was \(durationString, privacy: .public) hours ago. Not updating deny list. (< 24h)"
                )
                return
            }
            Logger.network.info("Updating deny list...")
            
            // Load the deny list
            let denyListURL = URL(string: "https://jonasfrey.de/appdata/moviedb-poster-blacklist.txt")!
            let (data, response) = try await Utils.request(from: denyListURL)
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                let bodyString = String(data: data, encoding: .utf8) ?? "nil"
                Logger.network.error(
                    // swiftlint:disable:next line_length
                    "Error updating deny list. HTTP response: \(response, privacy: .public), body: \(bodyString, privacy: .private)"
                )
                return
            }
            
            guard let text = String(data: data, encoding: .utf8) else {
                Logger.network.error("Error decoding deny list:\n\(data, privacy: .private)")
                return
            }
            
            var newDenyList: [String] = []
            let denyListLines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
            // Skip empty lines and comments
            for line in denyListLines where !line.isEmpty && !line.starts(with: "#") {
                if !line.starts(with: "/") {
                    // swiftlint:disable:next line_length
                    Logger.network.warning("Invalid line: '\(line, privacy: .private)'. Lines must begin with a '/'. Skipping...")
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
                Logger.background.error("Could not schedule app refresh: \(error, privacy: .public)")
            }
            
            // MARK: Create Operation
            let operation = Task {
                do {
                    Logger.background.info("Updating Library from background fetch...")
                    let updatedCount = try await MediaLibrary.shared.update()
                    Logger.background.info("Updated \(updatedCount) media objects.")
                    task.setTaskCompleted(success: updatedCount > 0)
                } catch {
                    Logger.background.error("Error executing background fetch: \(error, privacy: .public)")
                    task.setTaskCompleted(success: false)
                }
            }
            
            // MARK: Expiration Handler
            task.expirationHandler = {
                Logger.background.info("Cancelling background task...")
                operation.cancel()
            }
        }
    }
}
