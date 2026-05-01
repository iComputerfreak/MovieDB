//
//  MediaDetail.swift
//  Movie DB
//
//  Created by Jonas Frey on 06.07.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

struct MediaDetail: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            MediaDetailView()
        } else {
            MediaDetailLegacyView()
        }
    }
}

#Preview("Movie") {
    NavigationStack {
        MediaDetail()
            .environmentObject(PlaceholderData.preview.staticMovie as Media)
            .previewEnvironment()
    }
}

#Preview("Show") {
    NavigationStack {
        MediaDetail()
            .environmentObject(PlaceholderData.preview.staticShow as Media)
            .previewEnvironment()
    }
}
