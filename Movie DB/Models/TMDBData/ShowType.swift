//
//  ShowType.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

public enum ShowType: String, Decodable, CaseIterable {
    case documentary = "Documentary"
    case news = "News"
    case miniseries = "Miniseries"
    case reality = "Reality"
    case scripted = "Scripted"
    case talkShow = "Talk Show"
    case video = "Video"
}
