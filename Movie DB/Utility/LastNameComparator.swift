//
//  LastNameComparator.swift
//  Movie DB
//
//  Created by Jonas Frey on 28.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

struct LastNameComparator: SortComparator {
    typealias Compared = String
    
    var order: SortOrder
    
    func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsLastName = lhs.components(separatedBy: .whitespaces).last
        let rhsLastName = rhs.components(separatedBy: .whitespaces).last
        
        guard lhsLastName != rhsLastName else {
            return .orderedSame
        }
        
        guard let lhsLastName, !lhsLastName.isEmpty else {
            return .orderedDescending
        }
        guard let rhsLastName, !rhsLastName.isEmpty else {
            return .orderedAscending
        }
        
        // Sort by last name
        return lhsLastName.compare(rhsLastName)
    }
}
