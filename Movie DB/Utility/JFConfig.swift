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
    @ConfigValue(.showAdults, defaultValue: false) var showAdults: Bool {
        willSet {
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }

    /// The regionspecific language identifier consisting of an ISO 639-1 language code and an ISO 3166-1 region code separated by a dash
    @ConfigValue(.language, defaultValue: "") var language: String {
        willSet {
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }

    @ConfigValue(.region, defaultValue: Locale.current.regionCode ?? "") var region: String {
        willSet {
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }

    @ConfigValue(.availableLanguages, defaultValue: []) var availableLanguages: [String] {
        willSet {
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }
    
    var libraryWasReset = false
    
    private init() {}
    
    enum ConfigKey: String {
        case showAdults
        case region
        case language
        case availableLanguages
        case availableRegions
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
