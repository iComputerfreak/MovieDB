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

struct JFUtils {
    
    static let wordsIgnoredForSorting = [
        "the",
        "a"
    ]
    
    static var tmdbDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    /// Converts a string from the TMDB response into a `Date`
    /// - Parameter string: The date-string from TMDB
    static func dateFromTMDBString(_ string: String) -> Date? {
        return tmdbDateFormatter.date(from: string)
    }
    
    /// Returns the year component of the given date
    /// - Parameter date: The date
    static func yearOfDate(_ date: Date) -> Int {
        let cal = Calendar.current
        return cal.component(.year, from: date)
    }
    
    /// Convenience function to execute a HTTP GET request.
    /// Ignores errors and just passes nil to the completion handler.
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
        let urlStringWithParameters = "\(urlString)?\(parameters.percentEscaped())"
        var request = URLRequest(url: URL(string: urlStringWithParameters)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
    
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
    
    /// The URL describing the documents directory of the app
    static var documentsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Returns a date formatter to display `Date` values.
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
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
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
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
    
    // MARK: FSK Rating
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

extension Dictionary where Key == String, Value == Any? {
    /// Returns the dictionary as a string of HTTP arguments, percent escaped
    ///
    ///     [key1: "test", key2: "Hello World"].percentEscaped()
    ///     // Returns "key1=test&key2=Hello%20World"
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value ?? "null")".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    /// Returns the set of characters that are allowed in a URL query
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension String {
    /// Returns a string without a given prefix
    ///
    ///     "abc def".removingPrefix("abc") // returns " def"
    ///     "cba def".revmoingPrefix("abc") // returns "cba def"
    ///
    /// - Parameter prefix: The prefix to remove, if it exists
    /// - Returns: The string without the given prefix
    func removingPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) {
            return String(self.dropFirst(prefix.count))
        }
        // If the prefix does not exist, leave the string as it is
        return String(self)
    }
    /// Returns a string without a given suffix
    ///
    ///     "abc def".removingSuffix("def") // returns "abc "
    ///     "abc fed".revmoingSuffix("def") // returns "abc fed"
    ///
    /// - Parameter suffix: The suffix to remove, if it exists
    /// - Returns: The string without the given suffix
    func removingSuffix(_ suffix: String) -> String {
        if self.hasSuffix(suffix) {
            return String(self.dropFirst(suffix.count))
        }
        // If the prefix does not exist, leave the string as it is
        return String(self)
    }
    /// Removes a prefix from a string
    ///
    ///     let a = "abc def".removingPrefix("abc") // a is " def"
    ///     let b = "cba def".revmoingPrefix("abc") // b is "cba def"
    ///
    /// - Parameter prefix: The prefix to remove, if it exists
    /// - Returns: The string without the given prefix
    mutating func removePrefix(_ prefix: String) {
        if self.hasPrefix(prefix) {
            self.removeFirst(prefix.count)
        }
        // If the prefix does not exist, leave the string as it is
    }
    /// Removes a suffix from a string
    ///
    ///     let a = "abc def".removingSuffix("def") // a is "abc "
    ///     let b = "abc fed".revmoingSuffix("def") // b is "abc fed"
    ///
    /// - Parameter suffix: The suffix to remove, if it exists
    /// - Returns: The string without the given suffix
    mutating func removeSuffix(_ suffix: String) {
        if self.hasSuffix(suffix) {
            self.removeFirst(suffix.count)
        }
        // If the prefix does not exist, leave the string as it is
    }
}

extension NumberFormatter {
    func string(from value: Double) -> String? {
        return self.string(from: NSNumber(value: value))
    }
    
    func string(from value: Int) -> String? {
        return self.string(from: NSNumber(value: value))
    }
}

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
}
