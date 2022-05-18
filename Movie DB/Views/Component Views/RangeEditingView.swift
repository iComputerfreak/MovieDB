//
//  RangeEditingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a view in which you can choose a `ClosedRange` of values
struct RangeEditingView<Label, ValueLabel, T>: View
where T: Hashable, T: Strideable, T.Stride: SignedInteger, Label: View, ValueLabel: View {
    let title: Text
    let bounds: ClosedRange<T>
    @Binding var setting: ClosedRange<T>?
    let style: Style
    let fromLabel: (T) -> Label
    let toLabel: (T) -> Label
    let valueLabel: (T) -> ValueLabel
    
    private var proxies: (lower: Binding<T>, upper: Binding<T>) {
        FilterSetting.rangeProxies(for: $setting, bounds: bounds)
    }
    
    var body: some View {
        Group {
            if self.style == .stepper {
                self.makeStepperBody()
            }
        }
        .onDisappear {
            if self.setting == self.bounds {
                self.setting = nil
            }
        }
        .navigationBarItems(trailing: Button(String(
            localized: "generic.picker.navBar.button.reset",
            // swiftlint:disable:next line_length
            comment: "The navigation bar button label for the button that resets the currently visible range editing view"
        )) {
            self.setting = nil
        })
    }
    
    func makeStepperBody() -> some View {
        List {
            Stepper(value: self.proxies.lower, in: self.bounds.lowerBound ... self.proxies.upper.wrappedValue) {
                self.fromLabel(self.proxies.lower.wrappedValue)
            }
            Stepper(value: self.proxies.upper, in: self.proxies.lower.wrappedValue ... self.bounds.upperBound) {
                self.toLabel(self.proxies.upper.wrappedValue)
            }
            .navigationTitle(title)
        }
    }
    
    enum Style {
        case stepper
    }
}

// swiftlint:disable:next file_types_order
extension RangeEditingView where Label == HStack<TupleView<(Text, Spacer, ValueLabel)>> {
    /// Convenience init that synthesizes `fromLabel` and `toLabel` using `valueLabel`
    init(
        title: Text,
        bounds: ClosedRange<T>,
        setting: Binding<ClosedRange<T>?>,
        style: Style,
        valueLabel: @escaping (T) -> ValueLabel
    ) {
        self.init(
            title: title,
            bounds: bounds,
            setting: setting,
            style: style,
            fromLabel: { value in
                HStack {
                    Text(
                        "generic.picker.range.from",
                        // swiftlint:disable:next line_length
                        comment: "A range editing label that prefixes the actual value that is currently selected for the lower bound of the range."
                    )
                    Spacer()
                    valueLabel(value)
                }
            }, toLabel: { value in
                HStack {
                    Text(
                        "generic.picker.range.to",
                        // swiftlint:disable:next line_length
                        comment: "A range editing label that prefixes the actual value that is currently selected for the upper bound of the range."
                    )
                    Spacer()
                    valueLabel(value)
                }
            },
            valueLabel: valueLabel
        )
    }
}

// swiftlint:disable:next file_types_order
extension RangeEditingView where Label == Text, ValueLabel == Text, T: CustomStringConvertible {
    /// Convenience init for default labels
    init(title: Text, bounds: ClosedRange<T>, setting: Binding<ClosedRange<T>?>, style: Style) {
        self.init(
            title: title,
            bounds: bounds,
            setting: setting,
            style: style,
            fromLabel: { value in
                Text(
                    "generic.picker.range.from.value \(value.description)",
                    // swiftlint:disable:next line_length
                    comment: "A range editing label that describes the actual value that is currently selected for the lower bound of the range. The parameter is the value."
                )
            },
            toLabel: { value in
                Text(
                    "generic.picker.range.to.value \(value.description)",
                    // swiftlint:disable:next line_length
                    comment: "A range editing label that describes the actual value that is currently selected for the upper bound of the range. The parameter is the value."
                )
            },
            valueLabel: { Text($0.description) }
        )
    }
}

struct RangeEditingView_Previews: PreviewProvider {
    static var previews: some View {
//        RangeEditingView()
        Text("Not implemented")
    }
}
