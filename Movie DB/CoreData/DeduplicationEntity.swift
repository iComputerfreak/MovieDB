//
//  DeduplicationEntity.swift
//  Movie DB
//
//  Created by Jonas Frey on 21.02.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData

/// Represents a Core Data entity that must be duplicated when merging remote changes
enum DeduplicationEntity: CaseIterable {
    case media
    case movie
    case show
    case tag
    case genre
    case userMediaList
    case dynamicMediaList
    case filterSetting
    case productionCompany
    case season
    case video
    case watchProvider
    
    /// Returns the name of the associated Core Data entity
    var entityName: String {
        self.modelType.entity().name!
    }
    
    /// Returns the `NSManagedObject` subclass associated with this entity
    var modelType: NSManagedObject.Type {
        switch self {
        case .media:
            return Media.self
        case .movie:
            return Movie.self
        case .show:
            return Show.self
        case .tag:
            return Tag.self
        case .genre:
            return Genre.self
        case .userMediaList:
            return UserMediaList.self
        case .dynamicMediaList:
            return DynamicMediaList.self
        case .filterSetting:
            return FilterSetting.self
        case .productionCompany:
            return ProductionCompany.self
        case .season:
            return Season.self
        case .video:
            return Video.self
        case .watchProvider:
            return WatchProvider.self
        }
    }
}
