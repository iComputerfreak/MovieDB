//
//  PredicateMediaList.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import JFSwiftUI
import SwiftUI

/// Represents a media list that fetches its media objects by a fixed predicate
class PredicateMediaList: ObservableObject, MediaListProtocol {
    let name: String
    let listDescription: String?
    let iconName: String
    let predicate: NSPredicate
    let customFilter: ((Media) -> Bool)?
    let customSorting: ((Media, Media) -> Bool)?

    var sortingOrder: SortingOrder {
        willSet {
            // Send the objectWillChange signal to notify SwiftUI about the change
            // This would normally be done by `@Published`, but we need to do it manually here,
            // as `@Published` would not trigger the `didSet` observer to save the changes to UserDefaults.
            objectWillChange.send()
        }
        didSet {
            let key = Self.userDefaultsKey(for: name, type: .sortingOrder)
            UserDefaults.standard.set(sortingOrder.rawValue, forKey: key)
        }
    }

    var sortingDirection: SortingDirection {
        willSet {
            // Send the objectWillChange signal to notify SwiftUI about the change
            // This would normally be done by `@Published`, but we need to do it manually here,
            // as `@Published` would not trigger the `didSet` observer to save the changes to UserDefaults.
            objectWillChange.send()
        }
        didSet {
            let key = Self.userDefaultsKey(for: name, type: .sortingDirection)
            UserDefaults.standard.set(sortingDirection.rawValue, forKey: key)
        }
    }

    let subtitleContentUserDefaultsKey: String
    let defaultSubtitleContent: LibraryRow.SubtitleContent?
    var subtitleContent: LibraryRow.SubtitleContent? {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: subtitleContentUserDefaultsKey) else {
                return defaultSubtitleContent
            }
            return LibraryRow.SubtitleContent(rawValue: rawValue) ?? defaultSubtitleContent
        }
        set {
            objectWillChange.send()
            UserDefaults.standard.set(newValue?.rawValue, forKey: subtitleContentUserDefaultsKey)
        }
    }

    init(
        name: String,
        subtitleContentUserDefaultsKey: String,
        defaultSubtitleContent: LibraryRow.SubtitleContent?,
        description: String,
        iconName: String,
        defaultSortingOrder: SortingOrder? = nil,
        predicate: NSPredicate,
        customFilter: ((Media) -> Bool)? = nil,
        customSorting: ((Media, Media) -> Bool)? = nil
    ) {
        self.name = name
        self.subtitleContentUserDefaultsKey = subtitleContentUserDefaultsKey
        self.defaultSubtitleContent = defaultSubtitleContent
        self.listDescription = description
        self.iconName = iconName
        self.predicate = predicate
        self.customFilter = customFilter
        self.customSorting = customSorting
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
