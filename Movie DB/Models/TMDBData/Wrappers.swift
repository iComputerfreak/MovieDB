//
//  Wrappers.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

/// Respresents a wrapper containing the ID of a media and whether that media is an adult media or not.
struct MediaChangeWrapper: Codable {
    var id: Int
    var adult: Bool?
}
