//
//  MediaListProtocol.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

protocol MediaListProtocol: AnyObject, Hashable {
    var name: String { get }
    var iconName: String { get }
    var sortingOrder: SortingOrder { get set }
    var sortingDirection: SortingDirection { get set }
    func buildFetchRequest() -> NSFetchRequest<Media>
}
