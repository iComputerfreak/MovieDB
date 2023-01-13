//
//  AutoInvertingColor.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.01.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a Color that inverts its color while the device is in dark mode
struct AutoInvertingColor: View {
    @Environment(\.colorScheme) private var colorScheme
    let whiteValue: Double
    let darkSchemeOffset: Double
    
    /// Creates a new ``AutoInvertingColor``
    /// - Parameters:
    ///   - whiteValue: The white value between 0 and 1
    ///   - darkSchemeOffset: An offset that is added to the inverted white value, used in the dark scheme. Use this to make slight modifications to the inverted color
    init(whiteValue: Double, darkSchemeOffset: Double = 0) {
        self.whiteValue = whiteValue
        self.darkSchemeOffset = darkSchemeOffset
    }
    
    var body: some View {
        Color(white: colorScheme == .light ? whiteValue : 1 - whiteValue + darkSchemeOffset)
    }
}

struct AutoInvertingColor_Previews: PreviewProvider {
    static var previews: some View {
        AutoInvertingColor(whiteValue: 0.9, darkSchemeOffset: -0.1)
    }
}
