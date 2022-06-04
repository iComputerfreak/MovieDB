//
//  DefaultListRow.swift
//  Movie DB
//
//  Created by Jonas Frey on 04.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct DefaultListRow: View {
    let list: DefaultMediaList
    
    var body: some View {
        NavigationLink {
            FilteredMediaList(list: list)
        } label: {
            Label(list.name, systemImage: list.iconName)
                .symbolRenderingMode(.multicolor)
        }
    }
}

struct DefaultListRow_Previews: PreviewProvider {
    static var previews: some View {
        DefaultListRow(list: .favorites)
    }
}
