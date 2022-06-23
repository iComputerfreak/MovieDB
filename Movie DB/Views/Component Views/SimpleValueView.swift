//
//  SimpleValueView.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a single, editable value which can be chosen from a few options
struct SimpleValueView<T: Hashable>: View {
    @Environment(\.editMode) private var editMode
    
    let values: [T]
    @Binding var value: T
    var label: ((T) -> String)
    
    var body: some View {
        if editMode?.wrappedValue.isEditing ?? false {
            Picker(selection: $value, label: EmptyView()) {
                ForEach(values, id: \.self) { value in
                    Text(self.label(value))
                        .tag(value)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
        } else {
            Text(label(value))
        }
    }
    
    // Factory method
    static func createYesNo(value: Binding<Bool?>) -> SimpleValueView<Bool?> {
        SimpleValueView<Bool?>(values: [true, false, nil], value: value) { value in
            if let value = value {
                if value {
                    return Strings.Generic.pickerValueYes
                }
                return Strings.Generic.pickerValueNo
            } else {
                return "-"
            }
        }
    }
}

struct SimpleValueView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SimpleValueView(
                values: [true, false],
                value: .constant(false),
                label: { $0 ? "Yes" : "No" }
            )
            SimpleValueView<Bool>.createYesNo(value: .constant(true))
                .environment(\.editMode, .constant(.active))
        }
    }
}
