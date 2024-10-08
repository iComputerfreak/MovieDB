//
//  MediaContextMenu.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.07.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct MediaContextMenuModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contextMenu {
                Group {
                    Section {
                        AddToFavoritesButton()
                        AddToWatchlistButton()
                        AddEnvironmentMediaToListMenu()
                    }
                    Section {
                        ReloadMediaButton()
                        ShareMediaButton()
                        DeleteMediaButton()
                    }
                }
            }
    }
}

extension View {
    func mediaContextMenu() -> some View {
        self.modifier(MediaContextMenuModifier())
    }
}
