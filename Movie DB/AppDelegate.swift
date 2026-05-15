// Copyright © 2019 Jonas Frey. All rights reserved.

import BackgroundTasks
import Analytics
import CoreData
import Foundation
import JFSwiftUI
import os.log
import StoreKit
import TipKit
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    @UserDefault("lastAppStartUpdate", defaultValue: nil)
    private var lastAppStartUpdate: Date?

    private let backgroundHandler = BackgroundHandler()

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

        // MARK: Background Processing
        backgroundHandler.setupBackgroundFetch()

        AnalyticsService.shared.reloadFeatureFlags { [weak self] in
            guard let self else { return }

            Task(priority: .background) {
                let didSchedule = await self.backgroundHandler.refreshBackgroundFetch()
                Logger.background.info("Background fetch config refresh finished: \(didSchedule, privacy: .public)")
            }

            self.performAppLaunchBackgroundUpdateIfNeeded()
        }
        
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

    private func performAppLaunchBackgroundUpdateIfNeeded() {
        guard let interval = BackgroundHandler.currentBackgroundUpdateInterval else {
            Logger.library.info("Skipping app start library update because background updates are disabled.")
            return
        }

        guard lastAppStartUpdate == nil || lastAppStartUpdate!.distance(to: .now) > interval else {
            return
        }

        Task(priority: .background) {
            do {
                Logger.library.info("Updating media library after app start...")
                try await MediaLibrary.shared.reloadAll(fromBackground: true)
                Logger.library.info("App start update complete.")
                lastAppStartUpdate = .now
            } catch {
                Logger.library.error("Error updating media library after app start: \(error, privacy: .public)")
            }
        }
    }
    
    #if DEBUG
    private func handleDebugParameters() {
        let isUITesting = CommandLine.launchArguments.contains(.uiTesting)
        let isScreenshots = CommandLine.launchArguments.contains(.screenshots)

        if isUITesting || isScreenshots {
            JFConfig.shared.analyticsConsentState = .denied
            // Make sure the app does not ask for a rating during UI testing
            UserDefaults.standard.set(1, forKey: JFLiterals.Keys.askedForAppRating)
            UserDefaults.standard.set(true, forKey: JFLiterals.Keys.hasPurchasedPro)
            Tips.hideAllTipsForTesting()
        }

        if isUITesting {
            // Prepare a fresh container to do the UI testing in
            PersistenceController.prepareForUITesting()
            JFConfig.shared.region = "DE"
            JFConfig.shared.language = "en-US"
        } else if isScreenshots {
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
                    media.loadImages(force: true)
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
