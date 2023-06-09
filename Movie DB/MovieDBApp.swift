//
//  MovieDBApp.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

@main
struct MovieDBApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @ObservedObject private var config = JFConfig.shared
    @ObservedObject private var storeManager = StoreManager.shared
    
    var body: some Scene {
        WindowGroup {
            if config.language.isEmpty {
                LanguageChooser()
                    .environment(\.managedObjectContext, PersistenceController.viewContext)
                    .environmentObject(config)
            } else {
                ContentView()
                    .environment(\.managedObjectContext, PersistenceController.viewContext)
                    .environmentObject(storeManager)
                    .environmentObject(config)
            }
        }
    }
}
