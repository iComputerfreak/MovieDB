//
//  MediaMenu.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaMenu: View {
    var mediaObject: Media
    @Binding var viewConfig: MediaMenuViewConfig
    
    var body: some View {
        Menu {
            EditButton()
            // MARK: Favorite / Add to
            AddToSection(mediaObject: mediaObject, viewConfig: $viewConfig)
            // MARK: Actions
            ActionsSection(mediaObject: mediaObject, viewConfig: $viewConfig)
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

struct MediaMenu_Previews: PreviewProvider {
    static var previews: some View {
        MediaMenu(mediaObject: PlaceholderData.movie, viewConfig: .constant(.init()))
    }
}
