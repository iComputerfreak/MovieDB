// Copyright © 2023 Jonas Frey. All rights reserved.

import CoreData
import Foundation
import os.log
import SwiftUI

public extension ParentalRating {
    @NSManaged var id: UUID?
    var label: String {
        get { getTransformerValue(forKey: Schema.ParentalRating.label, defaultValue: "") }
        set { setTransformerValue(newValue, forKey: Schema.ParentalRating.label) }
    }
    
    var countryCode: String {
        get { getTransformerValue(forKey: Schema.ParentalRating.countryCode, defaultValue: "") }
        set { setTransformerValue(newValue, forKey: Schema.ParentalRating.countryCode) }
    }
    
    @NSManaged var medias: Set<Media>
    
    private var _color: CDColor? {
        get { getOptional(forKey: Schema.ParentalRating.color) }
        set { setOptional(newValue, forKey: Schema.ParentalRating.color) }
    }
    
    var uiColor: NSUIColor? {
        get { _color.map { NSUIColor(cdColor: $0) } }
        set { managedObjectContext.map { _color.update(from: newValue, in: $0) } }
    }
    
    var color: Color? {
        if let uiColor {
            return Color(platformColor: uiColor)
        }
        return nil
    }
    
    @nonobjc
    static func fetchRequest() -> NSFetchRequest<ParentalRating> {
        NSFetchRequest<ParentalRating>(entityName: Schema.ParentalRating._entityName)
    }
}

extension ParentalRating: Identifiable {}
