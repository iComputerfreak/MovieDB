//
//  MediaListProtocol.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

/// A list that displays media objects based on a custom `NSFetchRequest`
protocol MediaListProtocol: ObservableObject, Hashable {
    /// The name of the list
    var name: String { get }
    // We cannot call it `description`, as it would clash with the `CustomStringConvertible`'s `description`
    /// The user-visible description of what the list does
    var listDescription: String? { get }
    /// The subtitle content to display in this list. If the content is `nil`, the default value specified in the app settings will be used.
    var subtitleContent: LibraryRow.SubtitleContent? { get set }
    /// The SF Symbols name of the icon used for this list
    var iconName: String { get }
    /// The current ``SortingOrder`` used for this list
    var sortingOrder: SortingOrder { get set }
    /// The current ``SortingDirection`` used for this list
    var sortingDirection: SortingDirection { get set }
    /// A custom filter that is applied after fetching the objects from the store
    var customFilter: ((Media) -> Bool)? { get }
    /// A custom sorting that overrides the specified ``sortingOrder`` and ``sortingDirection``
    var customSorting: ((Media, Media) -> Bool)? { get }
    /// Builds the `NSFetchRequest` that fetches the media objects associated with this list
    func buildFetchRequest() -> NSFetchRequest<Media>
}

extension MediaListProtocol {
    var listDescription: String? { nil }
    var customFilter: ((Media) -> Bool)? { nil }
    var customSorting: ((Media, Media) -> Bool)? { nil }
}
