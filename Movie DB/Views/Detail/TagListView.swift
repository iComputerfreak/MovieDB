//
//  TagListView.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct TagListView: View {
    
    @Binding var tags: [Tag]
    
    init(_ tags: Binding<[Tag]>) {
        self._tags = tags
    }
    
    var body: some View {
        // TODO: Make fancy (capsules with shadow etc.)
        if tags.isEmpty {
            return Text("None")
        }
        return Text(tags.map({ $0.name }).joined(separator: ", "))
    }
}

struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        TagListView(.constant([]))
    }
}
