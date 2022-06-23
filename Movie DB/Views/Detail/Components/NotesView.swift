//
//  NotesView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct NotesView: View {
    @Binding var notes: String
    @Environment(\.editMode) private var editMode
    
    // swiftlint:disable:next type_contents_order
    init(_ notes: Binding<String>) {
        self._notes = notes
    }
    
    var body: some View {
        if editMode?.wrappedValue.isEditing ?? false {
            NavigationLink {
                EditView(notes: self.$notes)
            } label: {
                if notes.isEmpty {
                    Text(Strings.Detail.noNotesLabel)
                        .italic()
                } else {
                    self.label
                }
            }
        } else {
            self.label
        }
    }
    
    private var label: some View {
        Text(notes)
        .lineLimit(nil)
    }
    
    fileprivate struct EditView: View {
        @Binding var notes: String
        @Environment(\.colorScheme) private var colorScheme
        
        var body: some View {
            TextEditor(text: $notes)
                .textInputAutocapitalization(.sentences)
                .padding(5)
                .navigationTitle(Strings.Detail.notesNavBarTitle)
        }
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                NotesView(.constant("This is a simple test note.\nIt has four\nlines\nin total"))
                    .headline(verbatim: "Notes")
                NotesView(.constant("This one has only one."))
                    .headline(verbatim: "Notes")
                NotesView(.constant(""))
                    .headline(verbatim: "Notes")
                    .navigationTitle(Text(verbatim: "Test"))
            }
        }
        Group {
            NavigationView {
                NotesView.EditView(notes: .constant("This one is being edited."))
            }
            .previewDisplayName("Editing View")
        }
    }
}
