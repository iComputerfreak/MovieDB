//
//  Repairable.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.07.20.
//  Copyright © 2020 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

/// A set of problems that occurred while repairing
enum RepairProblems {
    /// No problems occurred
    case none
    /// Some problems occurred. Some were fixed, others maybe not
    case some(fixed: Int, notFixed: Int)
    
    static func + (lhs: RepairProblems, rhs: RepairProblems) -> RepairProblems {
        var fixed = 0
        var notFixed = 0
        switch lhs {
            case let .some(f, nf):
                fixed += f
                notFixed += nf
                break
            default:
                break
        }
        switch rhs {
            case let .some(f, nf):
                fixed += f
                notFixed += nf
                break
            default:
                break
        }
        
        if fixed == 0 && notFixed == 0 {
            return .none
        } else {
            return .some(fixed: fixed, notFixed: notFixed)
        }
    }
}

protocol Repairable {
    func repair(progress: Binding<Double>?) -> RepairProblems
}
