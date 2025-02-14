//
//  MovieDBApp.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import os.log
import SwiftUI
import TipKit

@main
struct MovieDBApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @ObservedObject private var config = JFConfig.shared

    private let storeManager: StoreManager = .shared

    var body: some Scene {
        WindowGroup {
            Group {
                if config.language.isEmpty {
                    LanguageChooser()
                        .environment(\.managedObjectContext, PersistenceController.viewContext)
                        .environmentObject(config)
                } else {
                    ContentView()
                        .environment(\.managedObjectContext, PersistenceController.viewContext)
                        .environmentObject(config)
                }
            }
            // Respond to universal links
            .openShareURLModifier()
            .task {
                do {
                    try Tips.configure()
                } catch {
                    Logger.tips.error("Failed to configure TipKit: \(error)")
                }
            }
        }
    }
}
