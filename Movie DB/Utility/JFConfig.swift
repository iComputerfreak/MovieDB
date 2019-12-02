//
//  JFConfig.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

struct JFConfig {
    
    static let shared: JFConfig = JFConfig()
    
    // MARK: - Settings
    @ConfigValue(.showAdults, defaultValue: false) var showAdults: Bool
    @ConfigValue(.country, defaultValue: "DE") var country: String
    @ConfigValue(.language, defaultValue: "de") var language: String
    // MARK: - Filter Settings
    @ConfigValue(.filterSettings, defaultValue: FilterSettings(), autoSave: false) var filterSettings: FilterSettings
    // MARK: - Other
    @ConfigValue(.tags, defaultValue: []) var tags: [Tag]
    
    private init() {}
    
    enum ConfigKey: String {
        case showAdults
        case country
        case language
        case filterSettings
        case tags
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
                    userDefaults.set(self.wrappedValue, forKey: key.rawValue)
                }
            }
        }
        /// Whether to automatically save the config value after it has been changed
        var autoSave: Bool
        
        init(_ key: ConfigKey, defaultValue: Value, autoSave: Bool = true) {
            self.key = key
            self.autoSave = autoSave
            // Load the value as PList encoded data
            if let data = userDefaults.data(forKey: key.rawValue) {
                do {
                    self.wrappedValue = try PropertyListDecoder().decode(Value.self, from: data)
                } catch let e {
                    print("Error decoding the config value for key \(key.rawValue). Using default value.")
                    print(e)
                    self.wrappedValue = defaultValue
                }
            } else {
                self.wrappedValue = defaultValue
            }
        }
        
        func save() {
            guard autoSave == false else {
                print("Calling save() on an ConfigValue with autoSave = true will have no effect.")
                return
            }
            // Save the value as a PList
            do {
                let encoded = try PropertyListEncoder().encode(self.wrappedValue)
                userDefaults.set(encoded, forKey: key.rawValue)
            } catch let e {
                print("Error encoding the config value \(self.wrappedValue) for key \(key.rawValue).")
                print(e)
            }
        }
    }
}
