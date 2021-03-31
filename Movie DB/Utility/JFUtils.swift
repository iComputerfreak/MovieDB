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
import CoreData

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
        formatter.locale = Locale(identifier: "en_US")
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
        
        let minShow = fetchMinMax(key: "firstAirDate", ascending: true)
        let minMovie = fetchMinMax(key: "releaseDate", ascending: true)
        let maxShow = fetchMinMax(key: "firstAirDate", ascending: false)
        let maxMovie = fetchMinMax(key: "releaseDate", ascending: false)
        
        let currentYear = Calendar.current.dateComponents([.year], from: Date()).year!
        let lowerBound: Int = min(minShow?.year, minMovie?.year) ?? currentYear
        let upperBound: Int = max(maxShow?.year, maxMovie?.year) ?? currentYear
        
        assert(lowerBound <= upperBound, "The fetch request returned wrong results. Try inverting the ascending/descending order of the fetch requests")
        
        return lowerBound ... upperBound
    }
    
    /// Returns a closed range containing the season counts from all media objects in the library
    static func numberOfSeasonsBounds() -> ClosedRange<Int> {
        let min = fetchMinMax(key: "numberOfSeasons", ascending: true) as? Show
        let max = fetchMinMax(key: "numberOfSeasons", ascending: false) as? Show
        
        if min?.numberOfSeasons == nil {
            return 0 ... (max?.numberOfSeasons ?? 0)
        }
        return min!.numberOfSeasons! ... (max?.numberOfSeasons ?? min!.numberOfSeasons!)
    }
    
    /// Returns a list of all genres existing in the viewContext.
    static func allGenres() -> [Genre] {
        return allObjects(entityName: "Genre")
    }
    
    /// Returns a list of all media objects existing in the viewContext.
    static func allMedias() -> [Media] {
        return allObjects(entityName: "Media")
    }
    
    /// Returns a list of all entities with the given name in the viewContext.
    static func allObjects<T: NSManagedObject>(entityName: String) -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
        let objects = try? PersistenceController.viewContext.fetch(fetchRequest)
        return objects ?? []
    }
    
    static private func fetchMinMax(key: String, ascending: Bool) -> Media? {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K != nil", key)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        fetchRequest.fetchLimit = 1
        return try? PersistenceController.viewContext.fetch(fetchRequest).first
    }
    
    
    /// An ISO8601 time string representing the current date and time. Safe to use in filenames
    /// - Parameter withTime: Whether to include the time
    /// - Returns: The date (and possibly time) string
    static func isoDateString(withTime: Bool = false) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withDashSeparatorInDate, .withFullDate]
        if withTime {
            formatter.formatOptions.formUnion([.withFullTime, .withTimeZone])
        }
        return formatter.string(from: Date())
    }
    
    static func share(items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        DispatchQueue.main.async {
            guard let source = UIApplication.shared.windows.last?.rootViewController else {
                return
            }
            let vc = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            vc.excludedActivityTypes = excludedActivityTypes
            vc.popoverPresentationController?.sourceView = source.view
            source.present(vc, animated: true)
        }
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
    
    /// Returns the human readable language name from the given locale string consisting of an ISO-639-1 language string and possibly an ISO-3166-1 region string
    ///
    ///     languageString("pt-BR") // Returns "Portuguese (Brazil)"
    ///     languageString("de") // Returns "German"
    static func languageString(for code: String, locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forIdentifier: code)
    }
    
    /// The `DateFormatter` for translating to and from TMDB date representation
    static var tmdbDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static func updateTMDBLanguages() {
        TMDBAPI.shared.getTMDBLanguageCodes { (codes, error) in
            guard let codes = codes else { return }
            // Sort the codes by the actual string that will be displayed, not the code itself
            let sortedCodes = codes.sorted(by: { code1, code2 in
                guard let displayString1 = Locale.current.localizedString(forIdentifier: code1) else {
                    return false
                }
                guard let displayString2 = Locale.current.localizedString(forIdentifier: code2) else {
                    return true
                }
                
                return displayString1.lexicographicallyPrecedes(displayString2)
            })
            UserDefaults.standard.set(sortedCodes, forKey: JFLiterals.Keys.tmdbLanguages)
        }
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

extension Dictionary {
    
    /// Merges the given dictionary with this dictionary by overriding the existing values with the given new values
    func merging(_ other: [Key : Value]) -> [Key : Value] {
        return self.merging(other, uniquingKeysWith: { _, new in new })
    }
    
    /// Merges the given dictionary with this dictionary by overriding the existing values with the given new values
    mutating func merge(_ other: [Key : Value]) {
        self.merge(other, uniquingKeysWith: { _, new in new })
    }
}

/// Returns the smaller non-nil object of the given two objects
/// - Parameters:
///   - x: The first object to compare
///   - y: The second object to compare
/// - Returns: The smaller non-nil object. If both objects are nil, the function returns nil.
func min<T>(_ x: T?, _ y: T?) -> T? where T : Comparable {
    if x == nil {
        return y
    }
    if y == nil {
        return x
    }
    return min(x!, y!)
}

/// Returns the bigger non-nil object of the given two objects
/// - Parameters:
///   - x: The first object to compare
///   - y: The second object to compare
/// - Returns: The bigger non-nil object. If both objects are nil, the function returns nil.
func max<T>(_ x: T?, _ y: T?) -> T? where T : Comparable {
    if x == nil {
        return y
    }
    if y == nil {
        return x
    }
    return max(x!, y!)
}

/// Array extension to make all arrays with hashable elements identifiable
extension Array: Identifiable where Element: Hashable {
    public var id: Int {
        return self.hashValue
    }
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

extension NSManagedObjectContext {
    
    override public var description: String {
        if let name = self.name {
            return "<NSManagedObjectContext: \(name)>"
        }
        //assertionFailure()
        return super.description
    }
}
