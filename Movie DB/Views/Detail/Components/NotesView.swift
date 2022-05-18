//
//  NotesView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI
import TextView

struct NotesView: View {
    @Binding var notes: String
    @Environment(\.editMode) private var editMode
    @State private var editingNotes = false
    
    // swiftlint:disable:next type_contents_order
    init(_ notes: Binding<String>) {
        self._notes = notes
    }
    
    var body: some View {
        Group {
            if editMode?.wrappedValue.isEditing ?? false {
                NavigationLink(destination: EditView(notes: self.$notes), isActive: $editingNotes) {
                    if notes.isEmpty {
                        Text(
                            "detail.userData.noNotes",
                            // swiftlint:disable:next line_length
                            comment: "Label in the detail view of a media object that describes the absence of any user-provided notes."
                        )
                            .italic()
                    } else {
                        self.label
                    }
                }
                .onTapGesture {
                    // Activate the navigation link manually
                    self.editingNotes = true
                }
            } else {
                self.label
            }
        }
    }
    
    private var label: some View {
        Text(notes)
        .lineLimit(nil)
    }
    
    fileprivate struct EditView: View {
        @Binding var notes: String
        @State private var isEditing = true
        @State private var responder = KeyboardResponder()
        @Environment(\.colorScheme) private var colorScheme
        
        init(notes: Binding<String>) {
            self._notes = notes
        }
        
        var body: some View {
            TextView(
                text: $notes,
                isEditing: $isEditing,
                textColor: Utils.primaryUIColor(colorScheme),
                backgroundColor: .clear,
                autocorrection: .default,
                autocapitalization: .sentences
            )
            .padding(5)
            .padding(.bottom, responder.height)
            .navigationBarTitle("Notes")
        }
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                NotesView(.constant("This is a simple test note.\nIt has four\nlines\nin total"))
                    .headline("Notes")
                NotesView(.constant("This one has only one."))
                    .headline("Notes")
                NotesView(.constant(""))
                    .headline("Notes")
                    .navigationTitle("Test")
            }
        }
        Group {
            NavigationView {
                NotesView.EditView(notes: .constant("This one is being edited."))
            }
        }
    }
}
