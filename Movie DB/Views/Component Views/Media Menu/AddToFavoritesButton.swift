//
//  AddToFavoritesButton.swift
//  Movie DB
//
//  Created by Jonas Frey on 27.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Analytics
import SwiftUI

struct AddToFavoritesButton: View {
    @EnvironmentObject private var mediaObject: Media
    var onAction: (() -> Void)? = nil

    var body: some View {
        Button {
            let newValue = !mediaObject.isFavorite
            onAction?()
            mediaObject.isFavorite.toggle()
            AnalyticsService.shared.track(.favoriteToggled(newValue: newValue))
        } label: {
            if mediaObject.isFavorite {
                Label(Strings.Detail.menuButtonUnfavorite, systemImage: "heart.fill")
            } else {
                Label(Strings.Detail.menuButtonFavorite, systemImage: "heart")
            }
        }
    }
}

#Preview {
    AddToFavoritesButton()
        .previewEnvironment()
}
