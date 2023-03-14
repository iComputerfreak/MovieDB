//
//  ParentalRating+CoreDataProperties.swift
//  Movie DB
//
//  Created by Jonas Frey on 14.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//
//

import CoreData
import Foundation
import os.log
import SwiftUI
import UIKit

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
    
    private var redComponent: CGFloat? {
        get { getOptional(forKey: Schema.ParentalRating.redComponent, defaultValue: nil) }
        set { setOptional(newValue, forKey: Schema.ParentalRating.redComponent) }
    }
    
    private var greenComponent: CGFloat? {
        get { getOptional(forKey: Schema.ParentalRating.greenComponent, defaultValue: nil) }
        set { setOptional(newValue, forKey: Schema.ParentalRating.greenComponent) }
    }
    
    private var blueComponent: CGFloat? {
        get { getOptional(forKey: Schema.ParentalRating.blueComponent, defaultValue: nil) }
        set { setOptional(newValue, forKey: Schema.ParentalRating.blueComponent) }
    }
    
    private var alphaComponent: CGFloat? {
        get { getOptional(forKey: Schema.ParentalRating.alphaComponent, defaultValue: nil) }
        set { setOptional(newValue, forKey: Schema.ParentalRating.alphaComponent) }
    }
    
    @NSManaged var medias: Set<Media>
    
    var uiColor: UIColor? {
        get {
            if let redComponent, let greenComponent, let blueComponent, let alphaComponent {
                return UIColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
            }
            return nil
        }
        set {
            if newValue == nil {
                self.redComponent = nil
                self.greenComponent = nil
                self.blueComponent = nil
            } else {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                newValue?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                self.redComponent = red
                self.greenComponent = green
                self.blueComponent = blue
                self.alphaComponent = alpha
            }
        }
    }
    
    var color: Color? {
        if let uiColor {
            return Color(uiColor: uiColor)
        }
        return nil
    }
    
    @nonobjc
    static func fetchRequest() -> NSFetchRequest<ParentalRating> {
        NSFetchRequest<ParentalRating>(entityName: Schema.ParentalRating._entityName)
    }
}

extension ParentalRating: Identifiable {}
