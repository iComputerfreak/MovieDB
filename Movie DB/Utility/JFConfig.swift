//
//  JFConfig.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

/// Represents all the config values that the user can change
class JFConfig: ObservableObject {
    static let shared = JFConfig()
    
    // MARK: - Settings
    
    // swiftlint:disable redundant_type_annotation
    @AppStorage("showAdults")
    var showAdults: Bool = false

    /// The regionspecific language identifier consisting of an ISO 639-1 language code and an ISO 3166-1 region code separated by a dash
    @AppStorage("language")
    var language: String = ""

    @AppStorage("region")
    var region: String = Locale.current.region?.identifier ?? ""

    // TODO: Does not work with @AppStorage yet.
    @ConfigValue(.availableLanguages, defaultValue: [])
    var availableLanguages: [String] {
        willSet {
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    @AppStorage("defaultWatchState")
    var defaultWatchState: GenericWatchState = .unknown
    
    // swiftlint:enable redundant_type_annotation
    
    private init() {}
    
    // TODO: Remove when @AppStorage works with [String]
    
    enum ConfigKey: String {
        case availableLanguages
    }
    
    /// Wraps a config value with a mechanism to load and save the value with the given key from/to `UserDefaults`
    @propertyWrapper
    struct ConfigValue<Value: Codable> {
        /// The UserDefaults instance to use
        let userDefaults = UserDefaults.standard
        
        /// The `ConfigKey` to use as key for `UserDefaults`
        let key: ConfigKey
        var wrappedValue: Value {
            didSet {
                if autoSave {
                    save()
                }
            }
        }

        /// Whether to automatically save the config value after it has been changed
        var autoSave: Bool
        
        init(_ key: ConfigKey, defaultValue: Value, autoSave: Bool = true) {
            self.key = key
            self.autoSave = autoSave
            wrappedValue = userDefaults.object(forKey: key.rawValue) as? Value ?? defaultValue
        }
        
        func save() {
            userDefaults.set(wrappedValue, forKey: key.rawValue)
        }
    }
}
