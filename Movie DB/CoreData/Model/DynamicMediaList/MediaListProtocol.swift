//
//  MediaListProtocol.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

protocol MediaListProtocol {
    var name: String { get }
    var iconName: String { get }
    func buildFetchRequest() -> NSFetchRequest<Media>
}
