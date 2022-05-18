//
//  Problem.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

struct Problem: Identifiable {
    let id = UUID()
    let type: ProblemType
    let associatedMedias: [Media]
}

enum ProblemType {
    case duplicateMedia
    
    var localized: String {
        switch self {
        case .duplicateMedia:
            return String(
                localized: "problemType.duplicateMedia.description",
                comment: "A type of library problem (e.g. duplicate medias)"
            )
        }
    }
    
    var recovery: String {
        switch self {
        case .duplicateMedia:
            return String(
                localized: "problemType.duplicateMedia.recovery",
                comment: "A recovery suggestion to resolve a library problem (e.g. duplicate medias)"
            )
        }
    }
}
