// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

private struct KeyedGeometryValuePreferenceKey<Value: Equatable>: PreferenceKey {
    static var defaultValue: [AnyHashable: Value] { [:] }

    static func reduce(value: inout [AnyHashable: Value], nextValue: () -> [AnyHashable: Value]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}

extension View {
    /// Reads a derived geometry value into the given binding using a caller-provided ID.
    /// Use stable IDs when multiple views in the same subtree read the same value type.
    /// - Parameters:
    ///   - id: Stable identifier for this geometry reader.
    ///   - value: The binding to update with the derived geometry value.
    ///   - transform: Closure that derives the value from the current geometry proxy.
    ///   - shouldUpdate: Closure that decides whether a new value should replace the current one.
    public func readGeometryValue<ID: Hashable, Value: Equatable>(
        id: ID,
        into value: Binding<Value>,
        transform: @escaping (GeometryProxy) -> Value,
        shouldUpdate: @escaping (Value, Value) -> Bool
    ) -> some View {
        let key = AnyHashable(id)

        return self
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: KeyedGeometryValuePreferenceKey<Value>.self, value: [key: transform(proxy)])
                }
            }
            .onPreferenceChange(KeyedGeometryValuePreferenceKey<Value>.self) { newValues in
                guard let newValue = newValues[key], shouldUpdate(value.wrappedValue, newValue) else { return }
                value.wrappedValue = newValue
            }
    }

    /// Reads the rendered width of a view into the given binding using a caller-provided ID.
    /// - Parameters:
    ///   - id: Stable identifier for this geometry reader.
    ///   - width: The binding to update with the rendered width.
    public func readWidth<ID: Hashable>(id: ID, into width: Binding<CGFloat>) -> some View {
        readGeometryValue(
            id: id,
            into: width,
            transform: \.size.width,
            shouldUpdate: { currentValue, newValue in
                // Only report the new value if it's a bit larger/smaller than the previous one.
                abs(currentValue - newValue) > 0.5
            }
        )
    }

    /// Reads the rendered height of a view into the given binding using a caller-provided ID.
    /// - Parameters:
    ///   - id: Stable identifier for this geometry reader.
    ///   - height: The binding to update with the rendered height.
    public func readHeight<ID: Hashable>(id: ID, into height: Binding<CGFloat>) -> some View {
        readGeometryValue(
            id: id,
            into: height,
            transform: { $0.size.height },
            shouldUpdate: { currentValue, newValue in
                // Only report the new value if it's a bit larger/smaller than the previous one.
                abs(currentValue - newValue) > 0.5
            }
        )
    }

    /// Reads the rendered size of a view into the given binding using a caller-provided ID.
    /// - Parameters:
    ///   - id: Stable identifier for this geometry reader.
    ///   - size: The binding to update with the rendered size.
    public func readSize<ID: Hashable>(id: ID, into size: Binding<CGSize>) -> some View {
        readGeometryValue(
            id: id,
            into: size,
            transform: { $0.size },
            shouldUpdate: { currentValue, newValue in
                // Only report the new value if it's a bit larger/smaller than the previous one.
                abs(currentValue.width - newValue.width) > 0.5 || abs(currentValue.height - newValue.height) > 0.5
            }
        )
    }
}
