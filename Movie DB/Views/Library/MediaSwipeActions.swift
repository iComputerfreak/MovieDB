//
//  MediaSwipeActions.swift
//  Movie DB
//
//  Created by Jonas Frey on 03.07.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func mediaSwipeActions() -> some View {
        self.modifier(MediaSwipeActionsModifier())
    }
}

struct MediaSwipeActionsModifier: ViewModifier {
    @EnvironmentObject private var mediaObject: Media
    
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                DeleteMediaSwipeAction()
                AddToWatchlistButton()
                    .labelStyle(.iconOnly)
                    .tint(.blue)
            }
    }
}
