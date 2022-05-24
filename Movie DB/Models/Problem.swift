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
            return Strings.ProblemType.duplicateMedia
        }
    }
    
    var recovery: String {
        switch self {
        case .duplicateMedia:
            return Strings.ProblemType.duplicateMediaRecovery
        }
    }
}
