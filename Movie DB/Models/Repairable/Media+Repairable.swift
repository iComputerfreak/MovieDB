//
//  Media+Repairable.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//
import Foundation
import SwiftUI

extension Media: Repairable {
    /// Attempts to identify problems and repair this media object by reloading the thumbnail, removing corrupted tags and re-loading the cast information
    /// - Parameter progress: A binding for the progress of the repair status
    /// - Returns: The number of fixed and not fixed problems
    func repair(progress: Binding<Double>? = nil) -> RepairProblems {
        // We have to check the following things:
        // tmdbData, thumbnail, tags (3 items)
        let progressStep = 1.0/3.0
        let group = DispatchGroup()
        var fixed = 0
        var notFixed = 0
        // If we have no TMDBData, we have no tmdbID and therefore no possibility to reload the data.
        guard let tmdbData = self.tmdbData else {
            print("[Verify] Media \(self.id) is missing the tmdbData. Not fixable.")
            progress?.wrappedValue = 1.0
            return .some(fixed: 0, notFixed: 1)
        }
        progress?.wrappedValue += progressStep
        // Thumbnail
        if self.thumbnail == nil && tmdbData.imagePath != nil {
            loadThumbnail()
            fixed += 1
            print("[Verify] '\(tmdbData.title)' (\(id)) is missing the thumbnail. Trying to fix it.")
        }
        progress?.wrappedValue += progressStep
        // Tags
        for tag in tags {
            // If the tag does not exist, remove it
            if !TagLibrary.shared.tags.map(\.id).contains(tag) {
                DispatchQueue.main.async {
                    self.tags.removeFirst(tag)
                    fixed += 1
                    print("[Verify] '\(tmdbData.title)' (\(self.id)) has invalid tags. Removed the invalid tags.")
                }
            }
        }
        progress?.wrappedValue += progressStep
        
        // TODO: Check, if tmdbData is complete, nothing is missing (e.g. cast, seasons, translations, keywords, ...)
        
        group.wait()
        // Make sure the progress is 100% (may be less due to rounding errors)
        progress?.wrappedValue = 1.0
        if fixed == 0 && notFixed == 0 {
            return .none
        } else {
            return .some(fixed: fixed, notFixed: notFixed)
        }
    }
}
