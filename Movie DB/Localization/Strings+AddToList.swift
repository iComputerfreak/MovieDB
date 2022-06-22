//
//  Strings+AddToList.swift
//  Movie DB
//
//  Created by Jonas Frey on 22.06.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation

extension Strings {
    enum AddToList {
        static let title = String(
            localized: "addToList.title",
            comment: "The title of the add to lists view, which lets the user select a list to add a media object to."
        )
        static let toolbarButtonCancel = String(
            localized: "addToList.toolbar.buttons.cancel",
            comment: "The cancel button in the add to lists view that dismisses the view without choosing a list."
        )
    }
}
