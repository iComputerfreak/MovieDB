//
//  CSVImporter.swift
//  Movie DB
//
//  Created by Jonas Frey on 16.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log
import SwiftCSV

/// Handles import of ``Media`` objects from a given CSV string or file URL.
class CSVImporter {
    let delimiter: Character
    let arraySeparator: Character
    let dateFormatter: DateFormatter
    let dateTimeFormatter: ISO8601DateFormatter
    
    private let csv: CSV<Named>
    
    init(
        string: String,
        delimiter: Character = CSVHelper.delimiter,
        arraySeparator: Character = CSVHelper.arraySeparator,
        dateFormatter: DateFormatter = CSVHelper.dateFormatter,
        dateTimeFormatter: ISO8601DateFormatter = CSVHelper.dateTimeFormatter
    ) throws {
        self.delimiter = delimiter
        self.arraySeparator = arraySeparator
        self.dateFormatter = dateFormatter
        self.dateTimeFormatter = dateTimeFormatter
        self.csv = try .init(string: string, delimiter: .character(delimiter), loadColumns: false)
    }
    
    init(
        url: URL,
        delimiter: Character = CSVHelper.delimiter,
        arraySeparator: Character = CSVHelper.arraySeparator,
        dateFormatter: DateFormatter = CSVHelper.dateFormatter,
        dateTimeFormatter: ISO8601DateFormatter = CSVHelper.dateTimeFormatter
    ) throws {
        self.delimiter = delimiter
        self.arraySeparator = arraySeparator
        self.dateFormatter = dateFormatter
        self.dateTimeFormatter = dateTimeFormatter
        self.csv = try .init(url: url, delimiter: .character(delimiter), loadColumns: false)
    }
    
    var header: [String] {
        csv.header
    }
    
    /// The total number of CSV rows parsed. Use this as the total when calculating a percentage in `CSVImporter.decodeMediaObjects`'s `onProgress` closure.
    var rowCount: Int {
        csv.rows.count
    }
    
    /// Decodes the parsed CSV contents and creates the ``Media`` objects
    ///
    /// The function first checks if the header contains all required keys as defined in `CSVManager.requiredImportKeys`.
    /// If this is not the case, an `CSVError.requiredHeaderMissing` error is thrown.
    ///
    /// Next, the function iterates over the CSV rows, calling `CSVManager.createMedia` to parse the individual rows into `Media` objects.
    /// After each row, the `onProgress` closure is called with the current number of imported lines. This count includes lines that have been skipped due to errors.
    ///
    /// At the end, all parsed `Media` objects are returned.
    ///
    /// - Parameters:
    ///   - importContext: The context to create the medias in
    ///   - onProgress: A closure that is called each time a new media has been decoded. The parameter is the count of already decoded objects.
    ///   - log: A closure that is called with a log message string each time new information is to be logged.
    /// - Returns: The decoded media objects
    /// - Throws: Fatal errors during decoding the media objects, such as missing headers or unexpected errors during decoding.
    func decodeMediaObjects(
        importContext: NSManagedObjectContext,
        onProgress: ((Int) -> Void)? = nil,
        log: ((String) -> Void)? = nil
    ) async throws -> [Media] {
        // MARK: Check header values
        // Check if the header contains the necessary values
        for headerValue in CSVHelper.requiredImportKeys where !self.header.contains(headerValue.rawValue) {
            log?("[Error] The CSV file does not contain the required header '\(headerValue)'.")
            Logger.importExport.error(
                "The CSV file does not contain the required header '\(headerValue.rawValue, privacy: .public)'."
            )
            // We cannot recover from this, so we throw an error
            throw CSVError.requiredHeaderMissing(headerValue)
        }
        for headerValue in CSVHelper.optionalImportKeys where !header.contains(headerValue.rawValue) {
            log?("[Warning] The CSV file does not contain the optional header '\(headerValue)'.")
            Logger.importExport.warning(
                "The CSV file does not contain the optional header '\(headerValue.rawValue, privacy: .public)'."
            )
            // Warn, but continue
        }
        
        let headerString = header.joined(separator: delimiter)
        log?("[Info] Importing CSV with header \(headerString)")
        Logger.importExport.info("Importing CSV with header \(headerString, privacy: .public)")
        
        // MARK: Loop over the CSV rows
        var medias: [Media] = []
        for (i, row) in csv.rows.enumerated() {
            // Textual representation of the CSV line (for error messages)
            lazy var line = row.values.joined(separator: String(delimiter))
            
            // Decode the CSV row and append it to the results, catch some CSVErrors and report them in both logs
            do {
                let media = try await createMedia(from: row, context: importContext)
                medias.append(media)
            } catch CSVError.noTMDBID {
                log?("[Error] The following line is missing a TMDB ID: \(line)")
                Logger.importExport.error(
                    // swiftlint:disable:next line_length
                    "Error while importing line '\(line, privacy: .private)' (line no. \(i + 1): Missing TMDB ID. Skipping line..."
                )
            } catch CSVError.noMediaType {
                log?("[Error] The following line is missing a media type: \(line)")
                Logger.importExport.error(
                    // swiftlint:disable:next line_length
                    "Error while importing line '\(line, privacy: .private)' (line no. \(i + 1)): Missing media type. Skipping line..."
                )
            } catch CSVError.mediaAlreadyExists {
                log?("[Warning] The following media already exists in your library: \(line)")
                Logger.importExport.warning(
                    // swiftlint:disable:next line_length
                    "Media from line '\(line, privacy: .private)' (line no. \(i + 1)) already exists in library. Skipping line..."
                )
            } catch let error as DecodingError {
                log?("[Error] Error while decoding line \(line). Skipping this line. \(error)")
                Logger.importExport.error(
                    // swiftlint:disable:next line_length
                    "Error while decoding line '\(line, privacy: .private)' (line no. \(i + 1)): \(error, privacy: .public)"
                )
            } catch {
                // If any other error occurs, log it and rethrow
                log?("[Error] Unexpected error: \(error.localizedDescription). Aborting.")
                Logger.importExport.fault(
                    "Unexpected error during import: \(error, privacy: .public). Aborting."
                )
                throw error
            }
            // Finished parsing line. Report progress
            onProgress?(i + 1) // We finished i + 1 lines
            // End of row parsing
        }
        
        return medias
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    /// Creates a ``Media`` object from the given key-value-pairs.
    ///
    /// The keys are expected to be the `rawValue`s of ``CSVKey``.
    ///
    /// - Parameters:
    ///   - values: The key-value-pairs to use for creating the new ``Media`` object
    ///   - context: The ``NSManagedObjectContext`` to create the media object in
    /// - Returns: The ``Media`` object
    private func createMedia(from values: [String: String], context: NSManagedObjectContext) async throws -> Media {
        // swiftlint:enable cyclomatic_complexity function_body_length
        
        // We only need the tmdbID and user values from the CSV
        guard let tmdbIDValue = values[.tmdbID], let tmdbID = Int(tmdbIDValue) else {
            throw CSVError.noTMDBID
        }
        guard let mediaTypeValue = values[.mediaType], let mediaType = MediaType(rawValue: mediaTypeValue) else {
            throw CSVError.noMediaType
        }
        
        // Check if media with this tmdbID already exists
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K = %d",
            Schema.Media.tmdbID.rawValue,
            tmdbID
        )
        fetchRequest.fetchLimit = 1
        let existingAmount = (try? context.count(for: fetchRequest)) ?? 0
        if existingAmount > 0 {
            // Media already exists in context
            throw CSVError.mediaAlreadyExists
        }
        
        // Create the media (TMDBAPI is an actor, so our thread does not matter here)
        let media = try await TMDBAPI.shared.media(for: tmdbID, type: mediaType, context: context)
        let arraySeparator = self.arraySeparator

        // From now on, we are working with media, so we need to be on the context's thread
        await context.perform {
            // Setting values with PartialKeyPaths is not possible, so we have to do it manually
            // Specifying ReferenceWritableKeyPaths in the dictionary with the converters is not possible, since the dictionary Value type would not be identical then
            if
                let personalRating = values[.personalRating]
                    .flatMap(Int.init)
                    .flatMap(StarRating.init(integerRepresentation:))
            {
                media.personalRating = personalRating
            }
            if let watchAgain = values[.watchAgain].flatMap(Bool.init) {
                media.watchAgain = watchAgain
            }
            if let rawTags = values[.tags] {
                var tags: [Tag] = []
                let tagNames = rawTags.split(separator: arraySeparator).map(String.init)
                if !tagNames.isEmpty {
                    for name in tagNames {
                        let tag = Tag.fetchOrCreate(name: name, in: context)
                        assert(tag.managedObjectContext == context)
                        tags.append(tag)
                    }
                    media.tags = Set(tags)
                }
            }
            if let notes = values[.notes] {
                media.notes = notes
            }
            if let watched = values[.movieWatched].flatMap(MovieWatchState.init(rawValue:)) {
                assert(mediaType == .movie)
                if let movie = media as? Movie {
                    movie.watched = watched
                }
            }
            // Legacy show watch state import
            if let watched = values[.showWatched].flatMap(ShowWatchState.init(rawValue:)) {
                assert(mediaType == .show)
                if let show = media as? Show {
                    show.watched = watched
                }
            }
            // New show watch state import
            if let lastSeasonWatched = values[.lastSeasonWatched].flatMap(Int.init) {
                let rawLastEpisodeWatched = values[.lastEpisodeWatched]
                let lastEpisodeWatched = rawLastEpisodeWatched == nil ? nil : Int(rawLastEpisodeWatched!)
                
                assert(mediaType == .show)
                if let show = media as? Show {
                    show.watched = .init(season: lastSeasonWatched, episode: lastEpisodeWatched)
                }
            }
            if let creationDate = values[.creationDate].flatMap(self.dateTimeFormatter.date(from:)) {
                media.creationDate = creationDate
            }
            if let modificationDate = values[.modificationDate].map(self.dateTimeFormatter.date(from:)) {
                media.modificationDate = modificationDate
            }
        }
        
        media.loadImages()
        
        return media
    }
}

private extension Dictionary where Key == String {
    subscript(key: CSVKey) -> Value? {
        get {
            self[key.rawValue]
        }
        set(newValue) {
            self[key.rawValue] = newValue
        }
    }
}
