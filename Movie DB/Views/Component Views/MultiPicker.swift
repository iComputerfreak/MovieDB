//
//  MultiPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import Foundation

/// Represents a Picker view that lets the user pick multiple values from a list
struct FilterMultiPicker<SelectionValue: Hashable, RowContent: View>: View {
    /// The actual binding to the original property
    @Binding var selectionBinding: [SelectionValue]
    // This property is solely used for updating the view and duplicates the above value
    // The above value does not update the view if the @Binding is not bound to a State or ObservedObject variable
    @State private var selection: [SelectionValue] {
        didSet {
            // When changing the selection, save the new value to the actual binding
            self.selectionBinding = self.selection
        }
    }
    /// The label closure, mapping the values to a view for representation in the list
    let label: (SelectionValue) -> RowContent
    /// The label of the Picker and the title in the editing view
    let title: Text
    /// The values to pick from
    @State var values: [SelectionValue]
    
    var body: some View {
        NavigationLink(destination: EditView(
            label: label,
            title: title,
            values: $values,
            selectionBinding: $selectionBinding,
            selection: $selection
        )) {
            HStack {
                self.title
                Spacer()
                if self.selection.isEmpty {
                    Text(Strings.Library.Filter.valueAny)
                        .foregroundColor(Color.secondary)
                } else if self.selection.count == 1 {
                    label(self.selection.first!)
                        .foregroundColor(Color.secondary)
                } else {
                    Text(Strings.Generic.pickerMultipleValuesLabel(self.selection.count))
                        .foregroundColor(Color.secondary)
                }
            }
        }
    }
    
    init(
        selection: Binding<[SelectionValue]>,
        label: @escaping (SelectionValue) -> RowContent,
        values: [SelectionValue],
        title: Text
    ) {
        self._selectionBinding = selection
        self._selection = State(wrappedValue: selection.wrappedValue)
        self.label = label
        self._values = State(wrappedValue: values)
        self.title = title
    }
    
    struct EditView: View {
        let label: (SelectionValue) -> RowContent
        let title: Text
        @Binding var values: [SelectionValue]
        @Binding var selectionBinding: [SelectionValue]
        @Binding var selection: [SelectionValue] {
            didSet {
                // When changing the selection, save the new value to the actual binding
                self.selectionBinding = self.selection
            }
        }
        
        var body: some View {
            List {
                if self.values.isEmpty {
                    HStack {
                        Spacer()
                        Text(Strings.Generic.pickerNoValuesLabel)
                            .italic()
                        Spacer()
                    }
                } else {
                    ForEach(self.values, id: \.self) { (value: SelectionValue) in
                        Button {
                            if self.selection.contains(value) {
                                self.selection.removeAll { $0 == value }
                                print("Removed \(value) to \(self.selection)")
                            } else {
                                self.selection.append(value)
                                print("Added \(value) to \(self.selection)")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                    .hidden(condition: !selection.contains(value))
                                self.label(value)
                                Spacer()
                            }
                        }
                        // Picker rows should not be blue
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle(title)
        }
    }
}

struct FilterMultiPicker_Previews: PreviewProvider {
    @State private static var selection: [String] = ["Value 1"]
    
    static var previews: some View {
        Form {
            FilterMultiPicker(
                selection: Self.$selection,
                label: { Text($0) },
                values: ["Value 1", "Value 2", "Value 3", "Value 4"],
                title: Text(verbatim: "Title")
            )
        }
        FilterMultiPicker.EditView(
            label: { Text($0) },
            title: Text("Title"),
            values: .constant(["Value 1", "Value 2", "Value 3", "Value 4"]),
            selectionBinding: .constant(["Value 2"]),
            selection: .constant(["Value 2"])
        )
    }
}
