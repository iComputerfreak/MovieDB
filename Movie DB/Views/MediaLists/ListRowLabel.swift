//
//  ListRowLabel.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.08.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct ListRowLabel<List: MediaListProtocol>: View {
    @ObservedObject var list: List

    init(list: List, symbolRenderingMode: SymbolRenderingMode = .multicolor) {
        self.list = list
    }
    
    var body: some View {
        Label(title: {
            Text(list.name)
        }, icon: {
            Image(systemName: list.iconName)
                .symbolRenderingMode(list.iconRenderingMode.symbolRenderingMode)
                .foregroundStyle(list.iconColor.map(Color.init) ?? .primaryIcon)
        })
    }
}

#Preview {
    List {
        ListRowLabel(list: PredicateMediaList.favorites)
        ListRowLabel(list: PredicateMediaList.watchlist)
        ListRowLabel(list: PredicateMediaList.newSeasons)
    }
}
