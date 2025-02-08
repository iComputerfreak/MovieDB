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
        // MARK: Prepare for UI testing or screenshots
        #if DEBUG
            handleDebugParameters()
        #endif
        
        // Initialize now to prevent it happening from a background thread later
        _ = PersistenceController.shared
        
        // MARK: Register transformers
        SerializableColorTransformer.register()
        EpisodeTransformer.register()
        
        // MARK: Update Poster Deny List
        loadDenyList()
        
        // MARK: Cleanup
        Task(priority: .background) {
            try MediaLibrary.shared.cleanup()
        }

        Task(priority: .background) {
            try? await Task.sleep(for: .seconds(3))
            let viewContext = PersistenceController.viewContext
            await viewContext.perform {
                do {
                    let sharedFilterSettingID = FilterSetting.shared.id ?? UUID()
                    // Get FilterSettings without a list and delete them
                    let request = FilterSetting.fetchRequest()
                    request.predicate = NSPredicate(format: "%K == nil", Schema.FilterSetting.mediaList.rawValue)
                    let orphanedFilterSettings = try viewContext.fetch(request)
                        .filter(where: \.id, isNotEqualTo: sharedFilterSettingID)
                    Logger.coreData.info("Cleaning up \(orphanedFilterSettings.count) orphaned filter settings.")
                    orphanedFilterSettings.forEach(viewContext.delete)
                    PersistenceController.saveContext()
                } catch {
                    Logger.coreData.error("Error cleaning up filter settings: \(error, privacy: .public)")
                }
            }
        }

        // MARK: Background Fetch
        // No need to keep a persistent reference
        let backgroundHandler = BackgroundHandler()
        backgroundHandler.setupBackgroundFetch()
        
        // MARK: Run Migrations
        
        let migrationManager = MigrationManager()
        
        migrationManager.register(DeleteOldPosterFilesMigration.self)
        migrationManager.register(ReloadLibraryMigration.self)
        
        migrationManager.run()
        
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
    
    #if DEBUG
    private func handleDebugParameters() {
        if CommandLine.launchArguments.contains(.uiTesting) {
            // Prepare a fresh container to do the UI testing in
            PersistenceController.prepareForUITesting()
            JFConfig.shared.region = "DE"
            JFConfig.shared.language = "en-US"
            // Make sure the app does not ask for a rating during UI testing
            UserDefaults.standard.set(1, forKey: JFLiterals.Keys.askedForAppRating)
        } else if CommandLine.launchArguments.contains(.screenshots) {
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
            prepareSamples()
        }
        if CommandLine.launchArguments.contains(.prepareSamples) {
            prepareSamples()
        }
    }
    
    /// Loads the view context with screenshot samples
    private func prepareSamples() {
        let bgContext = PersistenceController.viewContext.newBackgroundContext()
        // Add sample data
        Task(priority: .userInitiated) {
            // swiftlint:disable:next force_try
            try! await AppStoreScreenshotData(context: bgContext).prepareSampleData()
            await MainActor.run {
                // Commit to parent store (view context)
                // swiftlint:disable force_try
                try! bgContext.save()
                try! PersistenceController.viewContext.fetch(Media.fetchRequest()).forEach { media in
                    media.loadThumbnail(force: true)
                }
                // swiftlint:enable force_try
            }
        }
    }
    #endif
}

public extension CommandLine {
    enum LaunchArgument: String {
        case screenshots
        case prepareSamples = "prepare-samples"
        case uiTesting = "uitesting"
    }
    
    static var launchArguments: [LaunchArgument] {
        get {
            arguments.map { $0.removingPrefix("--") }.compactMap(LaunchArgument.init(rawValue:))
        }
        set {
            arguments = newValue.map(\.rawValue).map { "--\($0)" }
        }
    }
}
