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
public class CSVImporter {
    static let delimiter: CSVDelimiter = .character(CSVManager.separator)
    
    private let csv: CSV<Named>

    init(url: URL) throws {
        self.csv = try .init(url: url, delimiter: Self.delimiter, encoding: .utf8, loadColumns: false)
    }
    
    init(string: String) throws {
        self.csv = try .init(string: string, delimiter: Self.delimiter, loadColumns: false)
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
        for headerValue in CSVManager.requiredImportKeys where !self.header.contains(headerValue.rawValue) {
            log?("[Error] The CSV file does not contain the required header '\(headerValue)'.")
            Logger.importExport.error(
                "The CSV file does not contain the required header '\(headerValue.rawValue, privacy: .public)'."
            )
            // We cannot recover from this, so we throw an error
            throw CSVError.requiredHeaderMissing(headerValue)
        }
        for headerValue in CSVManager.optionalImportKeys where !header.contains(headerValue.rawValue) {
            log?("[Warning] The CSV file does not contain the optional header '\(headerValue)'.")
            Logger.importExport.warning(
                "The CSV file does not contain the optional header '\(headerValue.rawValue, privacy: .public)'."
            )
            // Warn, but continue
        }
        
        let headerString = header.joined(separator: Self.delimiter.rawValue)
        log?("[Info] Importing CSV with header \(headerString)")
        Logger.importExport.info("Importing CSV with header \(headerString, privacy: .public)")
        
        // MARK: Loop over the CSV rows
        var medias: [Media] = []
        for (i, row) in csv.rows.enumerated() {
            // Textual representation of the CSV line (for error messages)
            lazy var line = row.values.joined(separator: String(Self.delimiter.rawValue))
            
            // Decode the CSV row and append it to the results, catch some CSVErrors and report them in both logs
            do {
                let media = try await CSVManager.createMedia(from: row, context: importContext)
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
}
