//
//  JFLiterals.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct JFLiterals {
    /// The TMDB API Key
    static let apiKey = "e4304a9deeb9ed2d62eb61d7b9a2da71"
    /// Size multiplier for the size of the thumbnail in the `MediaDetail` view
    private static let _multiplier: CGFloat = 2.0
    /// The size of the thumbnail in the `LibraryHome` list
    static let thumbnailSize: CGSize = .init(width: 80.0 / 1.5, height: 80.0)
    /// The size of the thumbnail in the `MediaDetail` view
    static let detailPosterSize: CGSize = .init(width: JFLiterals.thumbnailSize.width * _multiplier, height: JFLiterals.thumbnailSize.height * _multiplier)
    /// The name of the poster placeholder image
    static let posterPlaceholderName = "PosterPlaceholder"
    /// The type property of trailer videos
    static let kTrailerVideoType = "Trailer"
    /// The maximum amount of pages to load when searching for media
    static let maxSearchPages = 10
    
    struct Keys {
        /// The key used for storing the TagLibrary
        static let allTags = "allTags"
        /// The key used for storing the MediaLibrary
        static let mediaLibrary = "mediaLibrary"
    }
}
