//
//  MultiPicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct FilterMultiPicker<SelectionValue>: View where SelectionValue: Hashable {
    
    @Binding var selection: [SelectionValue]
    let label: (SelectionValue) -> String
    let title: Text
    @State var values: [SelectionValue]
    
    init(selection: Binding<[SelectionValue]>, label: @escaping (SelectionValue) -> String, values: [SelectionValue], title: Text) {
        self._selection = selection
        self.label = label
        self._values = State(wrappedValue: values)
        self.title = title
    }
    
    var body: some View {
        NavigationLink(destination: self.editView, label: {
            HStack {
                self.title
                Spacer()
                if self.selection.isEmpty {
                    Text("Any")
                        .foregroundColor(Color.secondary)
                } else if self.selection.count == 1 {
                    Text("\(label(self.selection.first!))")
                        .foregroundColor(Color.secondary)
                } else {
                    Text("\(self.selection.count) Values")
                        .foregroundColor(Color.secondary)
                }
            }
        })
    }
    
    var editView: some View {
        List {
            ForEach(self.values, id: \.self) { (value: SelectionValue) in
                Button(action: {
                    if self.selection.contains(value) {
                        self.selection.removeAll(where: { $0 == value })
                    } else {
                        self.selection.append(value)
                    }
                }) {
                    HStack {
                        Text(self.label(value))
                        Spacer()
                        Image(systemName: "checkmark").hidden(condition: !self.selection.contains(value))
                    }
                }
                .foregroundColor(Color.primary)
            }
        }
    }
}

struct FilterMultiPicker_Previews: PreviewProvider {
    
    @State static private var selection: [String] = []
    
    static var previews: some View {
        Form {
            FilterMultiPicker(selection: Self.$selection, label: { $0 }, values: ["Value 1", "Value 2", "Value 3", "Value 4"], title: Text("Title"))
        }
    }
}
