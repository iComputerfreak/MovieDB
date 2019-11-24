//
//  SimpleValueView.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

/// Represents a single, editable value which can be chosen from a few options
struct SimpleValueView<T>: View {
    
    let values: [T]
    @Binding var value: T
    var label: ((T) -> String)
    
    var body: some View {
        Text(label(value))
    }
    
    // Factory method
    static func createYesNo(value: Binding<Bool?>) -> SimpleValueView<Bool?> {
        return SimpleValueView<Bool?>(values: [true, false, nil], value: value, label: { value in
            if let value = value {
                return value ? "Yes" : "No"
            } else {
                return "-"
            }
        })
    }
}

struct SimpleValueView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SimpleValueView(values: [true, false], value: .constant(false), label: { $0 ? "Yes" : "No" })
            SimpleValueView<Any>.createYesNo(value: .constant(true))
        }
    }
}
