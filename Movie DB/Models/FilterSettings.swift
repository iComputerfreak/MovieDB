//
//  FilterSettings.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct FilterSettings: Codable {
    
    // MARK: Smart Filters
    
    // MARK: Basic Filters
    var mediaType: MediaType? = nil
    var genres: [Genre] = []
    // var parentalRating
    var rating: ClosedRange<Int>? = nil
    var year: ClosedRange<Int>? = nil
    var status: [MediaStatus] = []
    // Show Specific
    var showType: [ShowType] = []
    var numberOfSeasons: ClosedRange<Int>? = nil
        
    // MARK: User Data
    var watched: Bool? = nil
    var watchAgain: Bool? = nil
    var tags: [Int] = []
    
    /// Creates two proxies for the upper and lower bound of the given range Binding
    ///
    /// Ensures that the set values never exceed the given bounds and that the set values form a valid range (`lowerBound <= upperBound`)
    ///
    /// - Parameters:
    ///   - setting: The binding for the `ClosedRange` to create proxies from
    ///   - bounds: The bounds of the range
    static func rangeProxies<T>(for setting: Binding<ClosedRange<T>?>, bounds: ClosedRange<T>) -> (lower: Binding<T>, upper: Binding<T>) {
        var lowerProxy: Binding<T> {
            Binding<T>(get: { setting.wrappedValue?.lowerBound ?? bounds.lowerBound }, set: { lower in
                // Ensure that we are not setting an illegal range
                var lower = max(lower, bounds.lowerBound)
                let upper = setting.wrappedValue?.upperBound ?? bounds.upperBound
                if lower > upper {
                    // Illegal range selected, set lower to lowest value possible
                    lower = upper
                }
                // Update the binding in the main thread (may be bound to UI)
                DispatchQueue.main.async {
                    setting.wrappedValue = lower ... upper
                }
            })
        }
        
        var upperProxy: Binding<T> {
            Binding<T>(get: { setting.wrappedValue?.upperBound ?? bounds.upperBound }, set: { upper in
                let lower = setting.wrappedValue?.lowerBound ?? bounds.lowerBound
                var upper = min(upper, bounds.upperBound)
                if lower > upper {
                    // Illegal range selected
                    upper = lower
                }
                // Update the binding in the main thread (may be bound to UI)
                DispatchQueue.main.async {
                    setting.wrappedValue = lower ... upper
                }
            })
        }
        
        return (lowerProxy, upperProxy)
    }
    
}
