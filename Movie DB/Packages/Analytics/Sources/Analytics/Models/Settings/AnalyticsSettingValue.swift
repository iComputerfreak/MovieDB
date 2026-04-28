//
//  AnalyticsSettingValue.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

public enum AnalyticsSettingValue: Sendable {
    case boolean(Bool)
    case integer(Int)
    case string(String)
    case stringArray([String])
}

extension AnalyticsSettingValue {
    var value: Any {
        switch self {
        case let .boolean(value):
            value
        case let .integer(value):
            value
        case let .string(value):
            value
        case let .stringArray(value):
            value
        }
    }
}
