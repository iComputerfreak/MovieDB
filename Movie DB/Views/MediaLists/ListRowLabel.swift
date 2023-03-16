//
//  ListRowLabel.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.08.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct ListRowLabel: View {
    let list: any MediaListProtocol
    
    var body: some View {
        Label(title: {
            Text(list.name)
        }, icon: {
            Image(systemName: list.iconName)
                .symbolRenderingMode(.multicolor)
        })
    }
}

struct ListRowLabel_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListRowLabel(list: PlaceholderData.Lists.favorites)
            ListRowLabel(list: PlaceholderData.Lists.newSeasons)
        }
    }
}
