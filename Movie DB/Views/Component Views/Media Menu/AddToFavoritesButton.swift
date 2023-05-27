//
//  MediaMenu+AddToFavorites.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct AddToFavoritesButton: View {
    @EnvironmentObject private var mediaObject: Media
    
    var body: some View {
        Button {
            mediaObject.isFavorite.toggle()
        } label: {
            if mediaObject.isFavorite {
                Label(Strings.Detail.menuButtonUnfavorite, systemImage: "heart.fill")
            } else {
                Label(Strings.Detail.menuButtonFavorite, systemImage: "heart")
            }
        }
    }
}

struct MediaMenu_AddToFavorites_Previews: PreviewProvider {
    static var previews: some View {
        AddToFavoritesButton()
            .environmentObject(PlaceholderData.preview.staticMovie)
    }
}
