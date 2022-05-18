//
//  ShowType.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

public enum ShowType: String, Codable, CaseIterable {
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
            return String(
                localized: "showType.documentary",
                comment: "A type of show (e.g. documentary, talk show, scripted)"
            )
        case .news:
            return String(
                localized: "showType.news",
                comment: "A type of show (e.g. documentary, talk show, scripted)"
            )
        case .miniseries:
            return String(
                localized: "showType.miniseries",
                comment: "A type of show (e.g. documentary, talk show, scripted)"
            )
        case .reality:
            return String(
                localized: "showType.reality",
                comment: "A type of show (e.g. documentary, talk show, scripted)"
            )
        case .scripted:
            return String(
                localized: "showType.scripted",
                comment: "A type of show (e.g. documentary, talk show, scripted)"
            )
        case .talkShow:
            return String(
                localized: "showType.talkShow",
                comment: "A type of show (e.g. documentary, talk show, scripted)"
            )
        case .video:
            return String(
                localized: "showType.video",
                comment: "A type of show (e.g. documentary, talk show, scripted)"
            )
        }
    }
}
