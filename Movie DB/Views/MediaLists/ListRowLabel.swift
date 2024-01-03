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
    let iconColor: Color
    let symbolRenderingMode: SymbolRenderingMode
    
    init(list: List, iconColor: Color = .accentColor, symbolRenderingMode: SymbolRenderingMode = .multicolor) {
        self.list = list
        self.iconColor = iconColor
        self.symbolRenderingMode = symbolRenderingMode
    }
    
    var body: some View {
        Label(title: {
            Text(list.name)
        }, icon: {
            Image(systemName: list.iconName)
                .symbolRenderingMode(symbolRenderingMode)
                .foregroundStyle(iconColor)
        })
    }
}

#Preview {
    List {
        ListRowLabel(list: PredicateMediaList.favorites, symbolRenderingMode: .multicolor)
        ListRowLabel(list: PredicateMediaList.newSeasons, iconColor: .mint, symbolRenderingMode: .palette)
    }
}
