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
    public let distinctID: String
    public let personProperties: [String: String]
    public let personPropertiesSetOnce: [String: String]

    public init(
        apiKey: String,
        host: String,
        isTrackingEnabled: Bool = false,
        distinctID: String,
        personProperties: [String: String] = [:],
        personPropertiesSetOnce: [String: String] = [:]
    ) {
        self.apiKey = apiKey
        self.host = host
        self.isTrackingEnabled = isTrackingEnabled
        self.distinctID = distinctID
        self.personProperties = personProperties
        self.personPropertiesSetOnce = personPropertiesSetOnce
    }
}
