//
//  ShowType.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

public enum ShowType: String, Codable, CaseIterable, Sendable {
    case documentary = "Documentary"
    case news = "News"
    case miniseries = "Miniseries"
    case reality = "Reality"
    case scripted = "Scripted"
    case talkShow = "Talk Show"
    case video = "Video"
    
    var localized: String {
        switch self {
        case .documentary:
            return Strings.ShowType.documentary
        case .news:
            return Strings.ShowType.news
        case .miniseries:
            return Strings.ShowType.miniseries
        case .reality:
            return Strings.ShowType.reality
        case .scripted:
            return Strings.ShowType.scripted
        case .talkShow:
            return Strings.ShowType.talkShow
        case .video:
            return Strings.ShowType.video
        }
    }
}
