//
//  AnalyticsSortingOrder.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

public enum AnalyticsSortingOrder: String, Sendable {
    case name
    case created
    case releaseDate = "release_date"
    case rating
    case watchDate = "watch_date"
}
