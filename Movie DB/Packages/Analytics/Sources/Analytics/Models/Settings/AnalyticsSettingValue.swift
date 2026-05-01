// Copyright © 2026 Jonas Frey. All rights reserved.

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
