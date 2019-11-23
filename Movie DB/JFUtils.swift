//
//  JFUtils.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit

/*enum JFLiterals: String {
    
}*/

struct JFUtils {
    
    /// Converts a string from the TMDB response into a `Date`
    /// - Parameter string: The date-string from TMDB
    static func dateFromTMDBString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
    
    /// Returns the year component of the given date
    /// - Parameter date: The date
    static func yearOfDate(_ date: Date) -> Int {
        let cal = Calendar.current
        return cal.component(.year, from: date)
    }
    
    /// Executes a HTTP GET request
    /// - Parameters:
    ///   - urlString: The URL string of the request
    ///   - parameters: The parameters for the request
    ///   - completion: The closure to execute on completion of the request
    static func getRequest(_ urlString: String, parameters: [String: Any?], completion: @escaping (Data?) -> Void) {
        let urlStringWithParameters = "\(urlString)?\(parameters.percentEscaped())"
        var request = URLRequest(url: URL(string: urlStringWithParameters)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        }.resume()
    }
    
    /// Builds the URL for an TMDB image
    /// - Parameters:
    ///   - path: The path of the image
    ///   - size: The size of the image
    static func getTMDBImageURL(path: String, size: Int = 500) -> String {
        return "https://image.tmdb.org/t/p/w\(size)/\(path)"
    }
    
    /// Returns the human readable language name (in english) from the given ISO-639-1 string
    ///
    ///     languageString("en") // Returns "English"
    static func languageString(_ string: String) -> String {
        // TODO: Fully implement
        return string == "en" ? "English" : string
    }
    
    /// Returns the human readable country name (in english) from the given ISO-3166-1 string
    ///
    ///     languageString("US") // Returns "United States"
    static func countryString(_ string: String) -> String {
        // TODO: Fully implement
        return string == "US" ? "United States" : string
    }
    
    /// The URL describing the documents directory of the app
    static var documentsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Returns an URL describing the directory with the given name in the documents directory and creates it, if neccessary
    /// - Parameter directory: The name of the folder in the documents directory
    static func url(for directory: String) -> URL {
        let url = documentsPath.appendingPathComponent(directory)
        // Create the directory, if it not already exists
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
}

struct JFLiterals {
    /// The TMDB API Key
    static let apiKey = "e4304a9deeb9ed2d62eb61d7b9a2da71"
    /// Size multiplier for the size of the thumbnail in the `MediaDetail` view
    private static let _multiplier: CGFloat = 2.0
    /// The size of the thumbnail in the `LibraryHome` list
    static let thumbnailSize: CGSize = .init(width: 80.0 / 1.5, height: 80.0)
    /// The size of the thumbnail in the `MediaDetail` view
    static let detailPosterSize: CGSize = .init(width: JFLiterals.thumbnailSize.width * _multiplier, height: JFLiterals.thumbnailSize.height * _multiplier)
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
