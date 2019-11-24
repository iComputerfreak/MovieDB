//
//  NotesView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct NotesView: View {
    
    var headline: String
    @Binding var notes: String
    // TODO: Implement editing
    
    init(_ notes: Binding<String>, headline: String) {
        self._notes = notes
        self.headline = headline
    }
    
    var body: some View {
        Text(notes)
            .lineLimit(nil)
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        NotesView(.constant(""), headline: "Notes")
    }
}
