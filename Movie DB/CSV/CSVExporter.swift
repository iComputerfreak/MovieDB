//
//  CSVExporter.swift
//  Movie DB
//
//  Created by Jonas Frey on 13.03.21.
//  Copyright © 2021 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import os.log
import RegexBuilder

/// Represents a static helper class to export media objects to and from CSV
class CSVExporter {
    // Keep as local properties, to be able to change them via an init, if we ever need to
    let separator: Character
    let arraySeparator: Character
    let lineSeparator: Character
    
    /// The `DateFormatter` used for de- and encoding dates
    let dateFormatter: DateFormatter

    /// The `ISO8601DateFormatter` used for de- and encoding dates that include a timestamp
    let dateTimeFormatter: ISO8601DateFormatter
    
    // This is a static helper class. We do not need to make instances of it.
    init(
        delimiter: Character = CSVHelper.delimiter,
        arraySeparator: Character = CSVHelper.arraySeparator,
        lineSeparator: Character = CSVHelper.lineSeparator,
        dateFormatter: DateFormatter = CSVHelper.dateFormatter,
        dateTimeFormatter: ISO8601DateFormatter = CSVHelper.dateTimeFormatter
    ) {
        self.separator = delimiter
        self.arraySeparator = arraySeparator
        self.lineSeparator = lineSeparator
        self.dateFormatter = dateFormatter
        self.dateTimeFormatter = dateTimeFormatter
    }
    
    // swiftlint:disable cyclomatic_complexity
    /// Creates a CSV record (line) from the given media object
    /// - Parameter media: The media object to export
    /// - Returns: The CSV line as a dictionary with all string values, keyed by their CSV header
    func createRecord(from media: Media) -> [CSVKey: String] {
        // swiftlint:enable cyclomatic_complexity
        var values: [CSVKey: String] = [:]
        for key in CSVHelper.exportKeys {
            var tuple: (Any, CSVHelper.Converter?)?
            
            // Extract the value by reading the KeyPath; Pass the converter to the tuple
            if let (keyPath, conv) = CSVHelper.exportKeyPaths[key] {
                let value = media[keyPath: keyPath]
                tuple = (value, conv)
            } else if let (keyPath, conv) = CSVHelper.movieExclusiveExportKeyPaths[key] {
                if let movie = media as? Movie {
                    let value = movie[keyPath: keyPath]
                    tuple = (value, conv)
                } else {
                    // If the media object is not a Movie, we leave the value blank
                    tuple = ("", nil)
                }
            } else if let (keyPath, conv) = CSVHelper.showExclusiveExportKeyPaths[key] {
                if let show = media as? Show {
                    let value = show[keyPath: keyPath]
                    tuple = (value, conv)
                } else {
                    // If the media object is not a Show, we leave the value blank
                    tuple = ("", nil)
                }
            } else {
                Logger.importExport.critical(
                    // swiftlint:disable:next line_length
                    "The key \(key.rawValue, privacy: .public) has no assigned KeyPath. Please add the key to one of the following dictionaries: keyPaths, movieExclusiveKeyPaths or showExclusiveKeyPaths."
                )
                fatalError("The key \(key) has no assigned KeyPath. Please add the key to one of the following " +
                    "dictionaries: keyPaths, movieExclusiveKeyPaths or showExclusiveKeyPaths.")
            }
            
            // Unwrap the value and converter
            var (value, converter) = tuple!
            
            // Convert the value, if a converter was given (and the value is not nil)
            if converter == nil {
                // Default converter
                converter = { "\($0)" }
            }
            
            // Convert the value to a string (and convert nil to "")
            var stringValue: String
            switch value {
            case Optional<Any>.none:
                // Map nil to ""
                stringValue = ""
            // Optional with value `some` or no Optional at all
            default:
                // Create a mirror of the object to read the `some` property of the Optional
                let mirror = Mirror(reflecting: value)
                // If value is an Optional
                if mirror.displayStyle == .optional {
                    // Since `value` is an Optional, it has exactly one property (`some`)
                    let unwrapped = mirror.children.first?.value
                    stringValue = converter!(unwrapped ?? "")
                } else {
                    // If value is no Optional, we don't need to unwrap it
                    stringValue = converter!(value)
                }
            }
            
            // Double all quotation marks in the value (escape them)
            stringValue = stringValue.replacingOccurrences(of: "\"", with: "\"\"")
            
            // If the value contains a separator, encapsulate the value in quotation marks
            if stringValue.contains(separator) {
                stringValue = "\"\(stringValue)\""
            }
            
            // Replace newlines and "\n"'s with spaces to prevent messing up the CSV file
            let regex = Regex {
                ChoiceOf {
                    OneOrMore(.newlineSequence)
                    OneOrMore("\\n") // "\n" string, not newline char
                }
            }
            stringValue.replace(regex) { _ in " " }
            
            // Save the value to the values dict
            values[key] = stringValue
        }
        
        return values
    }
    
    /// Creates a CSV string representing the given list of media objects
    /// - Parameter mediaObjects: The list of media objects to encode
    /// - Returns: The CSV string
    func createCSV(from mediaObjects: [Media]) -> String {
        var csv: [String] = []
        // CSV Header
        csv.append(CSVHelper.exportKeys.map(\.rawValue).joined(separator: separator))
        // CSV Values
        for mediaObject in mediaObjects {
            let values = createRecord(from: mediaObject)
            let line: [String] = CSVHelper.exportKeys.map { values[$0]! }
            csv.append(line.joined(separator: separator))
        }
        return csv.joined(separator: lineSeparator)
    }
}
