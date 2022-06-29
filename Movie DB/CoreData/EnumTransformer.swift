//
//  EnumTransformer.swift
//  Movie DB
//
//  Created by Jonas Frey on 05.02.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation

// swiftlint:disable:next file_types_order
public final class EnumStringTransformer<EnumType: RawRepresentable>: ValueTransformer
where EnumType.RawValue == String {
    public override static func transformedValueClass() -> AnyClass { NSString.self }
    
    public override static func allowsReverseTransformation() -> Bool { true }
    
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let enumValue = value as? EnumType else {
            fatalError("Trying to convert non-enum value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        return NSString(string: enumValue.rawValue)
    }
    
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let rawValue = value as? String else {
            fatalError("Trying to reverse convert non-string value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        return EnumType(rawValue: rawValue)
    }
}

public final class EnumIntTransformer<EnumType: RawRepresentable>: ValueTransformer where EnumType.RawValue == Int {
    public override class func transformedValueClass() -> AnyClass { NSNumber.self }
    
    public override class func allowsReverseTransformation() -> Bool { true }
    
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let enumValue = value as? EnumType else {
            fatalError("Trying to convert non-enum value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        return NSNumber(value: enumValue.rawValue)
    }
    
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let number = value as? NSNumber else {
            fatalError("Trying to reverse convert non-string value \(value ?? "nil") using " +
                       "EnumTransformer<\(String(describing: EnumType.self))>")
        }
        let rawValue = number.intValue as Int
        return EnumType(rawValue: rawValue)
    }
}
