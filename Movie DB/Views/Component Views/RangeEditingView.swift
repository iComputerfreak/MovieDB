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
    where T: Hashable, T: Strideable, T.Stride: SignedInteger, Label: View, ValueLabel: View
{ // swiftlint:disable:this opening_brace
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
        .navigationBarItems(trailing: Button(Strings.Generic.pickerNavBarButtonReset) {
            self.setting = nil
        })
    }
    
    func makeStepperBody() -> some View {
        List {
            Stepper(value: self.proxies.lower, in: self.bounds.lowerBound...self.proxies.upper.wrappedValue) {
                self.fromLabel(self.proxies.lower.wrappedValue)
            }
            Stepper(value: self.proxies.upper, in: self.proxies.lower.wrappedValue...self.bounds.upperBound) {
                self.toLabel(self.proxies.upper.wrappedValue)
            }
            .navigationTitle(title)
        }
    }
    
    enum Style {
        case stepper
    }
}

// swiftlint:disable:next large_tuple
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
                    Text(Strings.Generic.pickerRangeFromLabel)
                    Spacer()
                    valueLabel(value)
                }
            }, toLabel: { value in
                HStack {
                    Text(Strings.Generic.pickerRangeToLabel)
                    Spacer()
                    valueLabel(value)
                }
            },
            valueLabel: valueLabel
        )
    }
}

extension RangeEditingView where Label == Text, ValueLabel == Text, T: CustomStringConvertible {
    /// Convenience init for default labels
    init(title: Text, bounds: ClosedRange<T>, setting: Binding<ClosedRange<T>?>, style: Style) {
        self.init(
            title: title,
            bounds: bounds,
            setting: setting,
            style: style,
            fromLabel: { value in
                Text(Strings.Generic.pickerRangeFromValueLabel(value.description))
            },
            toLabel: { value in
                Text(Strings.Generic.pickerRangeToValueLabel(value.description))
            },
            valueLabel: { Text($0.description) }
        )
    }
}

#Preview {
    //        RangeEditingView()
    Text(verbatim: "Preview Not implemented")
}
