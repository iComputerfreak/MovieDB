//
//  AnalyticsConfiguration.swift
//  Analytics
//
//  Created by OpenCode on 27.04.26.
//

import Foundation

public struct AnalyticsConfiguration: Sendable {
    public let apiKey: String
    public let host: String
    public let isTrackingEnabled: Bool

    public init(apiKey: String, host: String, isTrackingEnabled: Bool = false) {
        self.apiKey = apiKey
        self.host = host
        self.isTrackingEnabled = isTrackingEnabled
    }
}
