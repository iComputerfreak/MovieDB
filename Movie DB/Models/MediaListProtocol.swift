//
//  MediaListProtocol.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

protocol MediaListProtocol: ObservableObject, Hashable {
    var name: String { get }
    // We cannot call it `description`, as it would clash with the `CustomStringConvertible`'s `description`
    var listDescription: String? { get }
    var iconName: String { get }
    var sortingOrder: SortingOrder { get set }
    var sortingDirection: SortingDirection { get set }
    var customFilter: ((Media) -> Bool)? { get }
    var customSorting: ((Media, Media) -> Bool)? { get }
    func buildFetchRequest() -> NSFetchRequest<Media>
}

extension MediaListProtocol {
    var listDescription: String? { nil }
    var customFilter: ((Media) -> Bool)? { nil }
    var customSorting: ((Media, Media) -> Bool)? { nil }
}
