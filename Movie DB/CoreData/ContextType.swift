// Copyright © 2023 Jonas Frey. All rights reserved.

import CoreData

/// Represents the different types of `NSManagedObjectContext`
enum ContextType: String {
    case viewContext
    case backgroundContext
    case disposableContext
}

extension NSManagedObjectContext {
    var type: ContextType? {
        get {
            guard let name else { return nil }
            return ContextType(rawValue: name)
        }
        set {
            self.name = newValue?.rawValue
        }
    }
}
