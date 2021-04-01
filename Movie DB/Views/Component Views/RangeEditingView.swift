//
//  RangeEditingView.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a view in which you can choose a `ClosedRange` of values
struct RangeEditingView<Label, ValueLabel, T>: View where T: Hashable, T: Strideable, T.Stride: SignedInteger, Label: View, ValueLabel: View {
    
    let title: String
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
            } else if self.style == .wheel {
                self.makeWheelBody()
            }
        }
        .onDisappear {
            if self.setting == self.bounds {
                self.setting = nil
            }
        }
        .navigationBarItems(trailing: Button(action: {
            self.setting = nil
        }, label: Text("Reset").closure()))
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
    
    func makeWheelBody() -> some View {
        List {
            GeometryReader { geometry in
                HStack {
                    // FUTURE: Pickers should only range from lower ... bounds or bounds ... upper (currently modifying the content of a picker throws an IndexOutOfRange Error)
                    Picker(selection: self.proxies.lower, label: Text("")) {
                        ForEach(self.bounds/*Array(self.bounds.lowerBound ... self.proxies.upper.wrappedValue)*/, id: \.self) { value in
                            self.valueLabel(value)
                                .tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .clipped()
                    
                    Picker(selection: self.proxies.upper, label: Text("")) {
                        ForEach(self.bounds/*Array(self.proxies.lower.wrappedValue ... self.bounds.upperBound)*/, id: \.self) { value in
                            self.valueLabel(value)
                                .tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width / 2, height: geometry.size.height)
                    .clipped()
                }
            }
                // FUTURE: Height has to be set manually, because of GeometryReader
                .frame(height: 216)
            .navigationTitle(title)
        }
        .labelsHidden()
    }
    
    enum Style {
        case stepper
        case wheel
    }
    
}

extension RangeEditingView where Label == HStack<TupleView<(Text, Spacer, ValueLabel)>> {
    /// Convenience init that synthesizes `fromLabel` and `toLabel` using `valueLabel`
    init(title: String, bounds: ClosedRange<T>, setting: Binding<ClosedRange<T>?>, style: Style, valueLabel: @escaping (T) -> ValueLabel) {
        self.init(title: title, bounds: bounds, setting: setting, style: style, fromLabel: { value in
            HStack {
                Text("From")
                Spacer()
                valueLabel(value)
            }
        }, toLabel: { value in
            HStack {
                Text("To")
                Spacer()
                valueLabel(value)
            }
        }, valueLabel: valueLabel)
    }
}

extension RangeEditingView where Label == Text, ValueLabel == Text, T: CustomStringConvertible {
    /// Convenience init for default labels
    init(title: String, bounds: ClosedRange<T>, setting: Binding<ClosedRange<T>?>, style: Style) {
        self.init(title: title, bounds: bounds, setting: setting, style: style, fromLabel: { Text("From \($0.description)") }, toLabel: { Text("To \($0.description)") }, valueLabel: { Text($0.description) })
    }
}

struct RangeEditingView_Previews: PreviewProvider {
    static var previews: some View {
        //RangeEditingView()
        Text("Not implemented")
    }
}
