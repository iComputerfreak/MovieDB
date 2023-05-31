//
//  PredicateMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import SwiftUI

/// Represents a media list that fetches its media objects by a fixed predicate
class PredicateMediaList: ObservableObject, MediaListProtocol {
    let name: String
    let description: String
    let iconName: String
    let predicate: NSPredicate
    let filter: ((Media) -> Bool)?
    
    var sortingOrder: SortingOrder {
        didSet {
            let key = Self.userDefaultsKey(for: name, type: .sortingOrder)
            UserDefaults.standard.set(sortingOrder.rawValue, forKey: key)
        }
    }

    var sortingDirection: SortingDirection {
        didSet {
            let key = Self.userDefaultsKey(for: name, type: .sortingDirection)
            UserDefaults.standard.set(sortingDirection.rawValue, forKey: key)
        }
    }
    
    init(
        name: String,
        description: String,
        iconName: String,
        defaultSortingOrder: SortingOrder? = nil,
        predicate: NSPredicate,
        filter: ((Media) -> Bool)? = nil
    ) {
        self.name = name
        self.description = description
        self.iconName = iconName
        self.predicate = predicate
        self.filter = filter
        // We know that the name is unique, because we only have a predefined set of names and the user cannot create
        // their own
        let orderKey = Self.userDefaultsKey(for: name, type: .sortingOrder)
        if
            let sortingOrderRawValue = UserDefaults.standard.string(forKey: orderKey),
            let order = SortingOrder(rawValue: sortingOrderRawValue)
        {
            sortingOrder = order
        } else {
            sortingOrder = defaultSortingOrder ?? .default
        }
        
        let directionKey = Self.userDefaultsKey(for: name, type: .sortingDirection)
        if
            let sortingDirectionRawValue = UserDefaults.standard.string(forKey: directionKey),
            let direction = SortingDirection(rawValue: sortingDirectionRawValue)
        {
            sortingDirection = direction
        } else {
            sortingDirection = sortingOrder.defaultDirection
        }
    }
    
    private static func userDefaultsKey(for name: String, type: StorageType) -> String {
        // !!!: Using the name as a unique key for persisting only works as long as we use the predicate lists
        // !!!: for default lists only with a well-defined set of possible names.
        "predicateList_\(type.rawValue)_\(name)"
    }
    
    func buildFetchRequest() -> NSFetchRequest<Media> {
        let fetch = Media.fetchRequest()
        fetch.predicate = predicate
        fetch.sortDescriptors = sortingOrder.createNSSortDescriptors(with: sortingDirection)
        return fetch
    }
    
    private enum StorageType: String {
        case sortingOrder
        case sortingDirection
    }
    
    // MARK: - Hashable Conformance
    
    // TODO: We cannot include `filter` in the Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(iconName)
        hasher.combine(predicate)
    }
    
    static func == (lhs: PredicateMediaList, rhs: PredicateMediaList) -> Bool {
        lhs.name == rhs.name &&
            lhs.iconName == rhs.iconName &&
            lhs.predicate == rhs.predicate
    }
}
