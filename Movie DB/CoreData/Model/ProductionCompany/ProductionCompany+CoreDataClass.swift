// Copyright © 2021 Jonas Frey. All rights reserved.

import CoreData
import Foundation

/// Represents a production company
@objc(ProductionCompany)
public class ProductionCompany: NSManagedObject {
    override public var description: String {
        if isFault {
            return "\(String(describing: Self.self))(isFault: true, objectID: \(objectID))"
        } else {
            return "\(String(describing: Self.self))(id: \(id), name: \(name))"
        }
    }
}
