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
    let iconColor: Color?
    
    init(list: List, iconColor: Color? = nil) {
        self.list = list
        self.iconColor = iconColor
    }
    
    var body: some View {
        Label(title: {
            Text(list.name)
        }, icon: {
            Image(systemName: list.iconName)
                .symbolRenderingMode(.multicolor)
                .foregroundColor(iconColor)
        })
    }
}

struct ListRowLabel_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListRowLabel(list: PredicateMediaList.favorites)
            ListRowLabel(list: PredicateMediaList.newSeasons, iconColor: .mint)
        }
    }
}
