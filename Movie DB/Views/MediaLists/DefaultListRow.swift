//
//  DefaultListRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct DefaultListRow<RowContent: View>: View {
    let list: DefaultMediaList
    let rowContent: (Media) -> RowContent
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        NavigationLink {
            FilteredMediaList(list: list, rowContent: rowContent)
        } label: {
            Label(list.name, systemImage: list.iconName)
                .symbolRenderingMode(.multicolor)
        }
        // Disable the destination during editing
        .disabled(editMode?.wrappedValue.isEditing ?? false)
    }
}

struct DefaultListRow_Previews: PreviewProvider {
    static var previews: some View {
        DefaultListRow(list: .favorites) { media in
            LibraryRow()
                .environmentObject(media)
        }
    }
}
