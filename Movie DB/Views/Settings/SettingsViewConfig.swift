//
//  SettingsViewConfig.swift
//  Movie DB
//
//  Created by Jonas Frey on 26.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

struct SettingsViewConfig {
    var showingProgress = false
    private(set) var progressText: String = ""
    var isLoading = false
    var loadingText: String?
    var languageChanged = false
    var regionChanged = false
    var isShowingProInfo = false
    var isShowingReloadCompleteNotification = false
    var importLogShowing = false
    var importLogger: TagImporter.BasicLogger?
    
    mutating func showProgress(_ text: String) {
        showingProgress = true
        progressText = text
    }
    
    mutating func hideProgress() {
        showingProgress = false
        progressText = ""
    }
}
