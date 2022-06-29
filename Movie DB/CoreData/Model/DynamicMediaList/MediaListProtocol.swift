//
//  MediaListProtocol.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

protocol MediaListProtocol {
    var name: String { get }
    var iconName: String { get }
    func buildFetchRequest() -> NSFetchRequest<Media>
}
