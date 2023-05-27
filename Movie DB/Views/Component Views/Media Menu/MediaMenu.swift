//
//  MediaMenu.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaMenu: View {
    // TODO: Make @EnvironmentObject?
    var mediaObject: Media
    
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        Menu {
            // MARK: Favorite / Add to
            AddToSection(mediaObject: mediaObject)
            // MARK: Actions
            ActionsSection(mediaObject: mediaObject, onDelete: onDelete)
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

struct MediaMenu_Previews: PreviewProvider {
    static var previews: some View {
        MediaMenu(mediaObject: PlaceholderData.preview.staticMovie)
    }
}
