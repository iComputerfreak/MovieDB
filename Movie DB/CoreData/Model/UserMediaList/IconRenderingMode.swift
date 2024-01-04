//
//  IconRenderingMode.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.09.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

public enum IconRenderingMode: String, CaseIterable {
    case multicolor
    case palette
    case hierarchical
    case monochrome
    
    var localized: String {
        switch self {
        case .multicolor:
            return String(
                localized: "generic.symbolRenderingMode.multicolor",
                comment: "Represents a rendering mode for an SF Symbol."
            )
        case .palette:
            return String(
                localized: "generic.symbolRenderingMode.palette",
                comment: "Represents a rendering mode for an SF Symbol."
            )
        case .hierarchical:
            return String(
                localized: "generic.symbolRenderingMode.hierarchical",
                comment: "Represents a rendering mode for an SF Symbol."
            )
        case .monochrome:
            return String(
                localized: "generic.symbolRenderingMode.monochrome",
                comment: "Represents a rendering mode for an SF Symbol."
            )
        }
    }
    
    var symbolRenderingMode: SymbolRenderingMode {
        switch self {
        case .multicolor:
            return .multicolor
        case .palette:
            return .palette
        case .hierarchical:
            return .hierarchical
        case .monochrome:
            return .monochrome
        }
    }
}
