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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.viewContext)
        }
    }
}
