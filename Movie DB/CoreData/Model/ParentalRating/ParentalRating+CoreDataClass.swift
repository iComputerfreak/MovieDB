// Copyright © 2023 Jonas Frey. All rights reserved.

import CoreData
import Foundation

@objc(ParentalRating)
public class ParentalRating: NSManagedObject {
    convenience init(context: NSManagedObjectContext, countryCode: String, label: String, color: NSUIColor? = nil) {
        self.init(context: context)
        self.countryCode = countryCode
        self.label = label
        self.uiColor = color
    }
}
