//
//  MediaLibrary+Repairable.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

extension MediaLibrary: Repairable {
    /// Attempts to fix all media objects in the library
    /// - Parameter progress: A binding for the progress of the repair status
    /// - Returns: The number of fixed and not fixed problems
    func repair(progress: Binding<Double>? = nil) -> RepairProblems {
        let progressStep: Double = 1.0 / Double(self.mediaList.count)
        var problems = RepairProblems.none
        // Reset the progress counter
        progress?.wrappedValue = 0.0
        
        // Don't check if there are duplicate IDs assigned, it's done in the problems tab already
        
        for mediaObject in mediaList {
            let result = mediaObject.repair()
            problems = problems + result
            DispatchQueue.main.async {
                progress?.wrappedValue += progressStep
            }
        }
        // Set the progress to 100% to fix any rounding errors
        DispatchQueue.main.async {
            progress?.wrappedValue = 1.0
        }
        return problems
    }
    
}
