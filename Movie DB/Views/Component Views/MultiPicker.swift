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
struct FilterMultiPicker<SelectionValue>: View where SelectionValue: Hashable {
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
    /// The label closure, mapping the values to a string for representation in the list
    let label: (SelectionValue) -> String
    /// The label of the Picker
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
                    Text(
                        "library.filter.value.any",
                        // swiftlint:disable:next line_length
                        comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
                    )
                        .foregroundColor(Color.secondary)
                } else if self.selection.count == 1 {
                    Text("\(label(self.selection.first!))")
                        .foregroundColor(Color.secondary)
                } else {
                    Text(
                        "generic.picker.multipleValues \(self.selection.count)",
                        // swiftlint:disable:next line_length
                        comment: "A picker label that indicates that there are currently multiple values selected. The parameter is the count of selected values."
                    )
                        .foregroundColor(Color.secondary)
                }
            }
        }
    }
    
    init(
        selection: Binding<[SelectionValue]>,
        label: @escaping (SelectionValue) -> String,
        values: [SelectionValue],
        titleKey: LocalizedStringKey,
        tableName: String? = nil,
        bundle: Bundle? = nil,
        comment: StaticString? = nil
    ) {
        self._selectionBinding = selection
        self._selection = State(wrappedValue: selection.wrappedValue)
        self.label = label
        self._values = State(wrappedValue: values)
        self.title = Text(titleKey, tableName: tableName, bundle: bundle, comment: comment)
    }
    
    struct EditView: View {
        let label: (SelectionValue) -> String
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
                        Text(
                            "generic.picker.noValues",
                            comment: "The label displayed by a picker when there are no possible values to pick from"
                        )
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
                                Text(self.label(value))
                                Spacer()
                                Image(systemName: "checkmark").hidden(condition: !self.selection.contains(value))
                            }
                        }
                        .navigationTitle(title)
                    }
                }
            }
        }
    }
}

struct FilterMultiPicker_Previews: PreviewProvider {
    @State private static var selection: [String] = []
    
    static var previews: some View {
        Form {
            FilterMultiPicker(
                selection: Self.$selection,
                label: { $0 },
                values: ["Value 1", "Value 2", "Value 3", "Value 4"],
                titleKey: "Title"
            )
        }
    }
}
