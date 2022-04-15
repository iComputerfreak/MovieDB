//
//  CSVHelper.swift
//  Movie DB
//
//  Created by Jonas Frey on 15.04.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

import Foundation
import CSVImporter
import CoreData

struct CSVHelper {
    
    static func importMediaObjects(csvString: String,
                                   importContext: NSManagedObjectContext,
                                   onProgress: ((Int) -> Void)? = nil,
                                   onFail: (([String]) -> Void)? = nil,
                                   onFinish: (([Media?], [String]) -> Void)?) {
        var importLog: [String] = []
        let importer: CSVImporter<Media?> = CSVImporter<Media?>(contentString: csvString, delimiter: String(CSVManager.separator))
        var csvHeader: [String] = []
        importer.startImportingRecords { (headerValues: [String]) in
            // Check if the header contains the necessary values
            for header in CSVManager.requiredImportKeys {
                if !headerValues.contains(header.rawValue) {
                    importLog.append("[Error] The CSV file does not contain the required header '\(header)'.")
                }
            }
            for header in CSVManager.optionalImportKeys {
                if !headerValues.contains(header.rawValue) {
                    importLog.append("[Warning] The CSV file does not contain the optional header '\(header)'.")
                }
            }
            importLog.append("[Info] Importing CSV with header \(headerValues.joined(separator: CSVManager.separator))")
            csvHeader = headerValues
        } recordMapper: { values in
            do {
                return try CSVManager.createMedia(from: values, context: importContext)
            } catch let error as CSVManager.CSVError {
                let line = csvHeader.map({ values[$0] ?? "" }).joined(separator: CSVManager.separator)
                switch error {
                    case .noTMDBID:
                        importLog.append("[Error] The following line is missing a TMDB ID:\n\(line)")
                    case .noMediaType:
                        importLog.append("[Error] The following line is missing a media type:\n\(line)")
                    case .mediaAlreadyExists:
                        importLog.append("[Warning] The following line already exists in the library. Skipping...\n\(line)")
                }
            } catch {
                // Other errors, e.g., error while fetching the TMDBData
                importLog.append("[Error] \(error.localizedDescription)")
            }
            return nil
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
}
