//
//  JFUtils.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension TimeZone {
    static let utc = TimeZone(secondsFromGMT: 0)!
}

/// Throws a fatal error when called. Used for setting undefined values temporarily to make the code compile
///
/// Example:
///
///     let value: String = undefined() // Will compile as a String
///     print(value.components(separatedBy: " ") // Will not throw any compiler errors
func undefined<T>(_ message: String = "") -> T {
    fatalError(message)
}

struct JFUtils {
    
    /// The words that will be ignored for sorting media objects in the library
    static let wordsIgnoredForSorting = [
        "the",
        "a"
    ]
        
    /// Convenience function to execute a HTTP GET request.
    /// Ignores errors and just passes nil to the completion handler, if the request failed.
    /// - Parameters:
    ///   - urlString: The URL string of the request
    ///   - parameters: The parameters for the request
    ///   - completion: The closure to execute on completion of the request
    static func getRequest(_ urlString: String, parameters: [String: Any?], completion: @escaping (Data?) -> Void) {
        getRequest(urlString, parameters: parameters) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("error", error ?? "Unknown error")
                completion(nil)
                return
            }
            
            // Check for http errors
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                print("headerFields = \(String(describing: response.allHeaderFields))")
                print("data = \(String(data: data, encoding: .utf8) ?? "nil")")
                completion(nil)
                return
            }
            
            completion(data)
        }
    }
    
    /// Executes a HTTP GET request
    /// - Parameters:
    ///   - urlString: The URL string of the request
    ///   - parameters: The parameters for the request
    ///   - completion: The closure to execute on completion of the request
    static func getRequest(_ urlString: String, parameters: [String: Any?], completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var urlStringWithParameters = "\(urlString)"
        // We should only append the '?', if we really have parameters
        if !parameters.isEmpty {
            urlStringWithParameters += "?\(parameters.percentEscaped())"
        }
        var request = URLRequest(url: URL(string: urlStringWithParameters)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("Making GET Request to \(urlStringWithParameters)")
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
    
    /// The URL describing the documents directory of the app
    static var documentsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Returns a date formatter to display `Date` values.
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    /// Returns a number formatter to display money values
    static var moneyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        return formatter
    }
    
    /// Returns an URL describing the directory with the given name in the documents directory and creates it, if neccessary
    /// - Parameter directory: The name of the folder in the documents directory
    static func url(for directory: String) -> URL {
        let url = documentsPath.appendingPathComponent(directory)
        // Create the directory, if it not already exists
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error creating folder in documents directory: \(error)")
        }
        return url
    }
    
    /// Returns either black or white, depending on the color scheme
    /// - Parameter colorScheme: The current color scheme environment variable
    static func primaryUIColor(_ colorScheme: ColorScheme) -> UIColor {
        return colorScheme == .light ? .black : .white
    }
    
    static func loadImage(urlString: String, completion: @escaping (UIImage?) -> ()) {
        print("Loading image from \(urlString)")
        JFUtils.getRequest(urlString, parameters: [:]) { (data) in
            guard let data = data else {
                print("Unable to get image")
                return
            }
            completion(UIImage(data: data))
        }
    }
    
    /// Returns a closed range containing the years of all media objects in the library
    static func yearBounds() -> ClosedRange<Int> {
        let currentYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 1970
        let years = MediaLibrary.shared.mediaList.compactMap({ $0.year }).sorted()
        guard !years.isEmpty else {
            return currentYear ... currentYear
        }
        return years.first! ... years.last!
    }
    
    /// Returns a closed range containing the season counts from all media objects in the library
    static func numberOfSeasonsBounds() -> ClosedRange<Int> {
        let seasons = MediaLibrary.shared.mediaList.compactMap({ (media: Media) in
            return (media.tmdbData as? TMDBShowData)?.numberOfSeasons
        }).sorted()
        guard !seasons.isEmpty else {
            return 0...0
        }
        return seasons.first! ... seasons.last!
    }
    
    /// Returns a list of genres used in the media library.
    /// Does not contain duplicates.
    static func allGenres() -> [Genre] {
        let genres = MediaLibrary.shared.mediaList.compactMap({ $0.tmdbData?.genres })
        // Remove all duplicates
        return Array(Set(genres.joined()))
    }
}

// MARK: - TMDB API
extension JFUtils {
    /// Builds the URL for an TMDB image
    /// - Parameters:
    ///   - path: The path of the image
    ///   - size: The size of the image
    static func getTMDBImageURL(path: String, size: Int = 500) -> String {
        return "https://image.tmdb.org/t/p/w\(size)/\(path)"
    }
    
    // TODO: Maybe load the strings from TMDB instead of using the Locale values
    // https://developers.themoviedb.org/3/configuration/get-languages
    /// Returns the human readable language name (in english) from the given ISO-639-1 string
    ///
    ///     languageString("en") // Returns "English"
    static func languageString(for code: String, locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forLanguageCode: code)
    }
    
    /// Returns the human readable region name (in english) from the given ISO-3166-1 string
    ///
    ///     languageString("US") // Returns "United States"
    static func regionString(for code: String, locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forRegionCode: code)
    }
    
    /// The `DateFormatter` for translating to and from TMDB date representation
    static var tmdbDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

// MARK: - FSK Rating
extension JFUtils {
    enum FSKRating: String, CaseIterable {
        case noRestriction = "0"
        case ageSix = "6"
        case ageTwelve = "12"
        case ageSixteen = "16"
        case ageEighteen = "18"
    }
    
    static func fskColor(_ rating: FSKRating) -> Color {
        switch rating {
            case .noRestriction:
                return Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0)
            case .ageSix:
                return Color(red: 255.0/255.0, green: 242.0/255.0, blue: 0.0/255.0)
            case .ageTwelve:
                return Color(red: 51.0/255.0, green: 255.0/255.0, blue: 0.0/255.0)
            case .ageSixteen:
                return Color(red: 51.0/255.0, green: 217.0/255.0, blue: 255.0/255.0)
            case .ageEighteen:
                return Color(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0)
        }
    }
    
    static func fskLabel(_ rating: FSKRating) -> some View {
        Image(systemName: "\(rating.rawValue).square")
            .foregroundColor(fskColor(rating))
    }
}
