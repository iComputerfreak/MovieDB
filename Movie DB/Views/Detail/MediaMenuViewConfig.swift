//
//  MediaMenuViewConfig.swift
//  Movie DB
//
//  Created by Jonas Frey on 08.09.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import SwiftUI

struct MediaMenuViewConfig {
    var isShowingAddedToListNotification = false
    private(set) var addedToListName: String = ""
    var isShowingReloadCompleteNotification = false
    
    mutating func showAddedToListNotification(listName: String) {
        addedToListName = listName
        isShowingAddedToListNotification = true
    }
}
