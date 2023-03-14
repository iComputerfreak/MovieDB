//
//  TMDBSearchResult.swift
//  Movie DB
//
//  Created by Jonas Frey on 29.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

/// Represents a search result from the TMDBAPI search call
class TMDBSearchResult: Decodable, Identifiable, ObservableObject, Hashable {
    // Basic Data
    /// The TMDB ID of the media
    let id: Int
    /// The name of the media
    let title: String
    /// The type of media
    let mediaType: MediaType
    /// The path of the media poster image on TMDB
    let imagePath: String?
    /// A short media description
    let overview: String?
    /// The original tile of the media
    let originalTitle: String
    /// The language the movie was originally created in as an ISO-639-1 string (e.g. 'en')
    let originalLanguage: String
    /// The thumbnail for this media
    var thumbnail: UIImage?
    
    // TMDB Scoring
    /// The popularity of the media on TMDB
    let popularity: Float
    /// The average rating on TMDB
    let voteAverage: Float
    /// The number of votes that were cast on TMDB
    let voteCount: Int
    /// Whether the result is a movie and is for adults only
    var isAdultMovie: Bool? { (self as? TMDBMovieSearchResult)?.isAdult }
    
    /// The task responsible for loading the thumbnail
    private var loadThumbnailTask: Task<Void, Never>?
    
    /// Creates a new `TMDBSearchResult` object with the given values
    init(
        id: Int,
        title: String,
        mediaType: MediaType,
        imagePath: String? = nil,
        overview: String? = nil,
        originalTitle: String,
        originalLanguage: String,
        popularity: Float,
        voteAverage: Float,
        voteCount: Int
    ) {
        self.id = id
        self.title = title
        self.mediaType = mediaType
        self.imagePath = imagePath
        self.overview = overview
        self.originalTitle = originalTitle
        self.originalLanguage = originalLanguage
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
    
    func loadThumbnail() {
        // If we are already downloading or already have a thumbnail, return
        guard self.loadThumbnailTask == nil, thumbnail == nil else {
            return
        }

        // Start loading the thumbnail
        // Use a dedicated overall task to be able to cancel it
        self.loadThumbnailTask = Task {
            guard !Task.isCancelled, let imagePath else {
                return
            }
            
            do {
                let thumbnail = try await TMDBImageService.mediaThumbnails.image(for: imagePath, downloadID: self.id)
                guard !Task.isCancelled else {
                    return
                }
                await MainActor.run {
                    self.objectWillChange.send()
                    self.thumbnail = thumbnail
                }
            } catch {
                Logger.addMedia.warning(
                    // swiftlint:disable:next line_length
                    "[\(self.title, privacy: .public)] Error (down-)loading thumbnail for search result: \(error) (mediaID: \(self.id, privacy: .public))"
                )
            }
        }
    }
    
    // swiftlint:disable type_contents_order
    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decodeAny(String.self, forKeys: [.title, .showTitle])
        mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        imagePath = try container.decode(String?.self, forKey: .imagePath)
        overview = try container.decode(String?.self, forKey: .overview)
        originalTitle = try container.decodeAny(String.self, forKeys: [.originalTitle, .originalShowTitle])
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        popularity = try container.decode(Float.self, forKey: .popularity)
        voteAverage = try container.decode(Float.self, forKey: .voteAverage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case showTitle = "name"
        case mediaType = "media_type"
        case imagePath = "poster_path"
        case overview
        case originalTitle = "original_title"
        case originalShowTitle = "original_name"
        case originalLanguage = "original_language"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    // MARK: Hashable Conformance
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(mediaType)
        hasher.combine(imagePath)
        hasher.combine(overview)
        hasher.combine(originalTitle)
        hasher.combine(originalLanguage)
        hasher.combine(popularity)
        hasher.combine(voteAverage)
        hasher.combine(voteCount)
    }
    
    static func == (lhs: TMDBSearchResult, rhs: TMDBSearchResult) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.mediaType == rhs.mediaType &&
            lhs.imagePath == rhs.imagePath &&
            lhs.overview == rhs.overview &&
            lhs.originalTitle == rhs.originalTitle &&
            lhs.originalLanguage == rhs.originalLanguage &&
            lhs.popularity == rhs.popularity &&
            lhs.voteAverage == rhs.voteAverage &&
            lhs.voteCount == rhs.voteCount
    }
}
