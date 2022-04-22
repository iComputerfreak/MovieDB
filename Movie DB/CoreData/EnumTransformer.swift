//
//  EnumTransformer.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import Foundation
import CoreData

public final class EnumStringTransformer<EnumType: RawRepresentable>: ValueTransformer
where EnumType.RawValue == String {
    
    override public static func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override public static func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let enumValue = value as? EnumType else {
            fatalError("Trying to convert non-enum value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        return NSString(string: enumValue.rawValue)
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let rawValue = value as? String else {
            fatalError("Trying to reverse convert non-string value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        return EnumType(rawValue: rawValue)
    }
}

public final class EnumIntTransformer<EnumType: RawRepresentable>: ValueTransformer where EnumType.RawValue == Int {
    
    override public class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let enumValue = value as? EnumType else {
            fatalError("Trying to convert non-enum value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        return NSNumber(value: enumValue.rawValue)
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let number = value as? NSNumber else {
            fatalError("Trying to reverse convert non-string value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        let rawValue = number.intValue as Int
        return EnumType(rawValue: rawValue)
    }
}
