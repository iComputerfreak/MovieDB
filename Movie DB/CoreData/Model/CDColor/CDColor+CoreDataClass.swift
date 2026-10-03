// Copyright © 2023 Jonas Frey. All rights reserved.

import CoreData
import Foundation
import JFUtils
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@objc(CDColor)
public class CDColor: NSManagedObject {
    convenience init(context: NSManagedObjectContext, uiColor: NSUIColor) {
        self.init(context: context)
        self.update(from: uiColor)
    }
    
    func update(from uiColor: NSUIColor) {
        let components = uiColor.components
        self.redComponent = components[0]
        self.greenComponent = components[1]
        self.blueComponent = components[2]
        self.alphaComponent = components[3]
    }
}
