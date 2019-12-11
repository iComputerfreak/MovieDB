//
//  JFConfig.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

class JFConfig: ObservableObject {
    
    static let shared = JFConfig()
    
    // MARK: - Settings
    @ConfigValue(.showAdults, defaultValue: false) var showAdults: Bool {
        didSet {
            objectWillChange.send()
        }
    }
    @ConfigValue(.region, defaultValue: Locale.current.regionCode ?? "US") var region: String {
        didSet {
            objectWillChange.send()
        }
    }
    @ConfigValue(.language, defaultValue: Locale.current.languageCode ?? "en") var language: String {
        didSet {
            objectWillChange.send()
        }
    }
    // MARK: - Other
    @ConfigValue(.tags, defaultValue: [], usePlist: true) var tags: [Tag] {
        didSet {
            objectWillChange.send()
        }
    }
    
    private init() {}
    
    enum ConfigKey: String {
        case showAdults
        case region
        case language
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
                    saveValue()
                }
            }
        }
        /// Whether to automatically save the config value after it has been changed
        var autoSave: Bool
        var usePlist: Bool
        
        init(_ key: ConfigKey, defaultValue: Value, autoSave: Bool = true, usePlist: Bool = false) {
            self.key = key
            self.autoSave = autoSave
            self.usePlist = usePlist
            // Load from user defaults directly, if primitive
            if !usePlist {
                self.wrappedValue = userDefaults.object(forKey: key.rawValue) as? Value ?? defaultValue
                return
            }
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
            saveValue()
        }
        
        // Does not have the check for autoSave like save()
        private func saveValue() {
            if !usePlist {
                userDefaults.set(wrappedValue, forKey: key.rawValue)
                return
            }
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
