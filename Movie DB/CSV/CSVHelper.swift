//
//  CSVHelper.swift
//  Movie DB
//
//  Created by Jonas Frey on 15.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import CoreData
import CSVImporter
import Foundation

struct CSVHelper {
    private init() {}
    
    // TODO: Make async and use continuation to return the result (or throw an error)
    static func importMediaObjects(
        csvString: String,
        importContext: NSManagedObjectContext,
        onProgress: ((Int) -> Void)? = nil,
        onFail: (([String]) -> Void)? = nil,
        onFinish: (([Media?], [String]) -> Void)?
    ) {
        var importLog: [String] = []
        let importer = CSVImporter<Media?>(
            contentString: csvString,
            delimiter: String(CSVManager.separator)
        )
        var csvHeader: [String] = []
        importer.startImportingRecords { (headerValues: [String]) in
            // Check if the header contains the necessary values
            for header in CSVManager.requiredImportKeys where !headerValues.contains(header.rawValue) {
                importLog.append("[Error] The CSV file does not contain the required header '\(header)'.")
            }
            for header in CSVManager.optionalImportKeys where !headerValues.contains(header.rawValue) {
                importLog.append("[Warning] The CSV file does not contain the optional header '\(header)'.")
            }
            importLog.append("[Info] Importing CSV with header \(headerValues.joined(separator: CSVManager.separator))")
            csvHeader = headerValues
        } recordMapper: { values in
            let group = DispatchGroup()
            group.enter()
            var result: Media?
            // We use the wrapper using a completion closure to make the async call to CSVManager.createMedia synchronous
            // (this recordMapper closure needs to be synchronous)
            createMedia(from: values, context: importContext) { media, error in
                defer { group.leave() }
                // CSVError
                if let error = error as? CSVManager.CSVError {
                    let line = csvHeader.map { values[$0] ?? "" }.joined(separator: CSVManager.separator)
                    switch error {
                    case .noTMDBID:
                        importLog.append("[Error] The following line is missing a TMDB ID:\n\(line)")
                    case .noMediaType:
                        importLog.append("[Error] The following line is missing a media type:\n\(line)")
                    case .mediaAlreadyExists:
                        importLog.append("[Warning] The following line already exists in the library. Skipping...\n" +
                            "\(line)")
                    }
                    return
                }
                // Any other error
                if let error {
                    print(error)
                    // Other errors, e.g., error while fetching the TMDBData
                    importLog.append("[Error] \(error.localizedDescription)")
                    return
                }
                guard let media else {
                    return
                }
                result = media
            }
            group.wait()
            return result
        }
        .onProgress { importedDataLinesCount in
            onProgress?(importedDataLinesCount)
        }
        .onFail {
            onFail?(importLog)
        }
        .onFinish { importedRecords in
            onFinish?(importedRecords, importLog)
        }
    }
    
    // Proxy to use the async function with a completion handler
    private static func createMedia(
        from values: [String: String],
        context: NSManagedObjectContext,
        completion: @escaping (Media?, Error?) -> Void
    ) {
        Task(priority: .userInitiated) {
            do {
                let media = try await CSVManager.createMedia(from: values, context: context)
                completion(media, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
