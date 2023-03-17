//
//  CDColor+CoreDataClass.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import UIKit

@objc(CDColor)
public class CDColor: NSManagedObject {
    convenience init(context: NSManagedObjectContext, uiColor: UIColor) {
        self.init(context: context)
        self.update(from: uiColor)
    }
    
    func update(from uiColor: UIColor) {
        let components = uiColor.components
        self.redComponent = components[0]
        self.greenComponent = components[1]
        self.blueComponent = components[2]
        self.alphaComponent = components[3]
    }
}
