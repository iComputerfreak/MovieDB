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
    @Binding var isEditing: Bool
    
    var body: some View {
        Menu {
            // TODO: Localize
            Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
            }
            // MARK: Favorite / Add to
            AddToSection(mediaObject: mediaObject)
            // MARK: Actions
            ActionsSection(mediaObject: mediaObject)
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

struct MediaMenu_Previews: PreviewProvider {
    static var previews: some View {
        MediaMenu(mediaObject: PlaceholderData.movie, isEditing: .constant(false))
    }
}
