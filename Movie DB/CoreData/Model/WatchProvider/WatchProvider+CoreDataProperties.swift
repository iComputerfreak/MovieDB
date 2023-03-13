//
//  WatchProvider+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

public extension WatchProvider {
    var id: Int {
        get { getInt(forKey: Schema.WatchProvider.id) }
        set { setInt(newValue, forKey: Schema.WatchProvider.id) }
    }
    
    @NSManaged var name: String
    var type: ProviderType? {
        get { getOptionalEnum(forKey: Schema.WatchProvider.type) }
        set { setOptionalEnum(newValue, forKey: Schema.WatchProvider.type) }
    }
    
    var priority: Int {
        get { getInt(forKey: Schema.WatchProvider.priority) }
        set { setInt(newValue, forKey: Schema.WatchProvider.priority) }
    }
    
    @NSManaged var imagePath: String?
    
    @NSManaged var medias: Set<Media>
    
    @NSManaged private var pngData: Data?
    
    /// The logo image of this watch provider
    var logoImage: UIImage? {
        get {
            if let pngData {
                return UIImage(data: pngData)
            }
            return nil
        }
        set {
            self.pngData = newValue?.pngData()
        }
    }
    
    enum ProviderType: String {
        case flatrate
        case ads
        case buy
        
        var priority: Int {
            switch self {
            case .flatrate:
                return 10
            case .ads:
                return 5
            case .buy:
                return 0
            }
        }
        
        var localized: String {
            switch self {
            case .flatrate:
                return Strings.WatchProvider.flatrate
            case .ads:
                return Strings.WatchProvider.ads
            case .buy:
                return Strings.WatchProvider.buy
            }
        }
    }
    
    @nonobjc
    static func fetchRequest() -> NSFetchRequest<WatchProvider> {
        NSFetchRequest<WatchProvider>(entityName: Schema.WatchProvider._entityName)
    }
}

extension WatchProvider: Identifiable {}
