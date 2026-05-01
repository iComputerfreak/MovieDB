// Copyright © 2023 Jonas Frey. All rights reserved.

import CoreData
import Foundation
import UIKit

@objc(ParentalRating)
public class ParentalRating: NSManagedObject {
    convenience init(context: NSManagedObjectContext, countryCode: String, label: String, color: UIColor? = nil) {
        self.init(context: context)
        self.label = label
        self.uiColor = color
    }
}
