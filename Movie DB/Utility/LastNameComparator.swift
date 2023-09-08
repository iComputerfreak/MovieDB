//
//  LastNameComparator.swift
//  Movie DB
//
//  Created by Jonas Frey on 28.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

/// Compares two names by their last name, using the first name as a tie breaker
struct LastNameComparator: SortComparator {
    typealias Compared = String
    
    var order: SortOrder
    
    func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsComponents = lhs.components(separatedBy: .whitespaces)
        let rhsComponents = rhs.components(separatedBy: .whitespaces)
        
        let lastNameResult = compareOptional(lhsComponents.last, rhsComponents.last)
        
        if lastNameResult == .orderedSame {
            // If the last name matches, order by the first name
            return compareOptional(lhsComponents.first, rhsComponents.first)
        }
        
        return lastNameResult
    }
    
    private func compareOptional(_ lhs: String?, _ rhs: String?) -> ComparisonResult {
        guard lhs != rhs else {
            return .orderedSame
        }
        
        guard let lhs, !lhs.isEmpty else {
            return .orderedDescending
        }
        guard let rhs, !rhs.isEmpty else {
            return .orderedAscending
        }
        
        return lhs.compare(rhs)
    }
}
