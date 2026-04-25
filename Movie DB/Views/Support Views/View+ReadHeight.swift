//
//  View+ReadHeight.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.04.26.
//  Copyright © 2026 Jonas Frey. All rights reserved.
//

import SwiftUI

private struct GeometryValuePreferenceKey<Value: Equatable>: PreferenceKey {
    static var defaultValue: Value? { nil }

    static func reduce(value: inout Value?, nextValue: () -> Value?) {
        value = nextValue() ?? value
    }
}

extension View {
    /// Reads a derived geometry value into the given binding.
    /// - Parameters:
    ///   - value: The binding to update with the derived geometry value.
    ///   - transform: Closure that derives the value from the current geometry proxy.
    ///   - shouldUpdate: Closure that decides whether a new value should replace the current one.
    public func readGeometryValue<Value: Equatable>(
        into value: Binding<Value>,
        transform: @escaping (GeometryProxy) -> Value,
        shouldUpdate: @escaping (Value, Value) -> Bool
    ) -> some View {
        self
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: GeometryValuePreferenceKey<Value>.self, value: transform(proxy))
                }
            }
            .onPreferenceChange(GeometryValuePreferenceKey<Value>.self) { newValue in
                guard let newValue, shouldUpdate(value.wrappedValue, newValue) else { return }
                value.wrappedValue = newValue
            }
    }

    /// Reads the rendered height of a view into the given binding.
    /// - Parameter height: The binding to update with the rendered height.
    public func readHeight(into height: Binding<CGFloat>) -> some View {
        readGeometryValue(into: height, transform: { $0.size.height }) { currentValue, newValue in
            // Only report the new value if it's a bit larger/smaller than the previous one.
            abs(currentValue - newValue) > 0.5
        }
    }
}
