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
            objectWillChange.send()
        }
    }
    @ConfigValue(.region, defaultValue: Locale.current.regionCode ?? "US") var region: String {
        willSet {
            objectWillChange.send()
        }
    }
    @ConfigValue(.language, defaultValue: Locale.current.languageCode ?? "en") var language: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    private init() {}
    
    enum ConfigKey: String {
        case showAdults
        case region
        case language
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
            self.wrappedValue = userDefaults.object(forKey: key.rawValue) as? Value ?? defaultValue
        }
        
        func save() {
            userDefaults.set(wrappedValue, forKey: key.rawValue)
        }
    }
}
