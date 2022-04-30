//
//  Utils.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import CoreData
import StoreKit
import JFUtils

/// Throws a fatal error when called. Used for setting undefined values temporarily to make the code compile
///
/// Example:
///
///     let value: String = undefined() // Will compile as a String
///     print(value.components(separatedBy: " ") // Will not throw any compiler errors
// swiftlint:disable:next unavailable_function
func undefined<T>(_ message: String = "") -> T {
    fatalError(message)
}

struct Utils {
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
    
    private init() {}
    
    /// Executes an HTTP request with the given URL
    /// - Parameter url: The URL to request
    /// - Returns: The data and URLResponse
    static func request(from url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("Making GET Request to \(request.url?.absoluteString ?? "nil")")
        #if DEBUG
        // In Debug mode, always load the URL, never use the cache
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        #endif
        return try await URLSession.shared.data(for: request)
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
        colorScheme == .light ? .black : .white
    }
    
    /// Downloads an image using the given URL
    /// - Parameter url: The URL to download the image from
    /// - Returns: The downloaded UIImage
    static func loadImage(from url: URL) async throws -> UIImage {
        print("Loading image from \(url.absoluteString)")
        let (data, response) = try await Self.request(from: url)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299) ~= httpResponse.statusCode
        else {
            print("statusCode should be 2xx, but is \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            print("response = \(response)")
            print("data = \(String(data: data, encoding: .utf8) ?? "nil")")
            throw HTTPError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw JFError.decodingError
        }
        
        return image
    }
    
    /// Returns a closed range containing the years of all media objects in the library
    static func yearBounds(context: NSManagedObjectContext) -> ClosedRange<Int> {
        let minShow = fetchMinMaxShow(key: "firstAirDate", ascending: true, context: context)
        let minMovie = fetchMinMaxMovie(key: "releaseDate", ascending: true, context: context)
        let maxShow = fetchMinMaxShow(key: "firstAirDate", ascending: false, context: context)
        let maxMovie = fetchMinMaxMovie(key: "releaseDate", ascending: false, context: context)
        
        let currentYear = Calendar.current.dateComponents([.year], from: Date()).year!
        let lowerBound: Int = min(minShow?.year, minMovie?.year) ?? currentYear
        let upperBound: Int = max(maxShow?.year, maxMovie?.year) ?? currentYear
        
        assert(lowerBound <= upperBound, "The fetch request returned wrong results. " +
               "Try inverting the ascending/descending order of the fetch requests")
        
        return lowerBound ... upperBound
    }
    
    /// Returns a closed range containing the season counts from all media objects in the library
    static func numberOfSeasonsBounds(context: NSManagedObjectContext) -> ClosedRange<Int> {
        let min = fetchMinMaxShow(key: "numberOfSeasons", ascending: true, context: context)
        let max = fetchMinMaxShow(key: "numberOfSeasons", ascending: false, context: context)
        
        if min?.numberOfSeasons == nil {
            return 0 ... (max?.numberOfSeasons ?? 0)
        }
        return min!.numberOfSeasons! ... (max?.numberOfSeasons ?? min!.numberOfSeasons!)
    }
    
    /// Returns a list of all genres existing in the viewContext, sorted by id and not including duplicates.
    static func allGenres(context: NSManagedObjectContext) -> [Genre] {
        allObjects(entityName: "Genre", context: context)
            .removingDuplicates { $0.id == $1.id && $0.name == $1.name }
            .sorted(by: \.name)
    }
    
    /// Returns a list of all media objects existing in the viewContext.
    static func allMedias(context: NSManagedObjectContext) -> [Media] {
        allObjects(entityName: "Media", context: context)
            .removingDuplicates(key: \.id)
            .sorted(by: \.id)
    }
    
    /// Returns a list of all entities with the given name in the given context.
    static func allObjects<T: NSManagedObject>(entityName: String, context: NSManagedObjectContext) -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
        let objects = try? context.fetch(fetchRequest)
        return objects ?? []
    }
    
    private static func fetchMinMaxMovie(key: String, ascending: Bool, context: NSManagedObjectContext) -> Movie? {
        fetchMinMax(fetchRequest: Movie.fetchRequest(), key: key, ascending: ascending, context: context)
    }
    
    private static func fetchMinMaxShow(key: String, ascending: Bool, context: NSManagedObjectContext) -> Show? {
        fetchMinMax(fetchRequest: Show.fetchRequest(), key: key, ascending: ascending, context: context)
    }
    
    private static func fetchMinMax<T>(
        fetchRequest: NSFetchRequest<T>,
        key: String,
        ascending: Bool,
        context: NSManagedObjectContext
    ) -> T? {
        let fetchRequest = fetchRequest
        fetchRequest.predicate = NSPredicate(format: "%K != nil", key)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        fetchRequest.fetchLimit = 1
        return try? context.fetch(fetchRequest).first
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
        Task(priority: .userInitiated) {
            await MainActor.run {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return
                }
                guard let source = scene.windows.last?.rootViewController else {
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
    
    static func purchasedPro() -> Bool {
        // TODO: Revert before deploying
        true
//        UserDefaults.standard.bool(forKey: JFLiterals.inAppPurchaseIDPro)
    }
    
    /// Returns the human readable language name from the given locale string consisting of an ISO-639-1 language string and possibly an ISO-3166-1 region string
    ///
    ///     languageString("pt-BR") // Returns "Portuguese (Brazil)"
    ///     languageString("de") // Returns "German"
    static func languageString(for code: String, locale: Locale = Locale.current) -> String? {
        locale.localizedString(forIdentifier: code)
    }
    
    static func parentalRating(for label: String) -> ParentalRating? {
        // We use FSKRating for Germany and ContentRating for everything else
        if JFConfig.shared.region.lowercased() == "de" {
            // The given label should be one of the FSK labels
            switch label {
            case ParentalRating.fskNoRestriction.label:
                return ParentalRating.fskNoRestriction
            case ParentalRating.fskAgeSix.label:
                return ParentalRating.fskAgeSix
            case ParentalRating.fskAgeTwelve.label:
                return ParentalRating.fskAgeTwelve
            case ParentalRating.fskAgeSixteen.label:
                return ParentalRating.fskAgeSixteen
            case ParentalRating.fskAgeEighteen.label:
                return ParentalRating.fskAgeEighteen
            default:
                // If the label is not one of the FSK labels, we just use the default return value below
                break
            }
        }
        return ParentalRating(label)
    }
}

// MARK: - TMDB
// swiftlint:disable:next file_types_order
extension Utils {
    /// The list of TMDB image paths to not download
    static var posterDenyList = UserDefaults.standard.array(forKey: JFLiterals.Keys.posterDenyList) as? [String] ?? []
    
    /// The `DateFormatter` for translating to and from TMDB date representation
    static var tmdbDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .utc
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// Builds the URL for an TMDB image
    /// - Parameters:
    ///   - path: The path of the image
    ///   - size: The size of the image. Must be a size supported by the TMDB API
    static func getTMDBImageURL(path: String, size: Int?) -> URL {
        // Don't load images on the deny list (should be checked before calling this function and replace with a placeholder image)
        guard !posterDenyList.contains(path) else {
            print("Poster path \(path) is on deny list. Not fetching.")
            assertionFailure("This should have been prevented from being called for poster paths on the deny list " +
                             "in the first place.")
            // As a fallback, load the placeholder as thumbnail
            return URL(string: "https://www.jonasfrey.de/appdata/PosterPlaceholder.png")!
        }
        let sizeString = size != nil ? "w\(size!)" : "original"
        return URL(string: "https://image.tmdb.org/t/p/\(sizeString)/\(path)")!
    }
    
    @discardableResult
    static func updateTMDBLanguages() async throws -> [String] {
        let codes = try await TMDBAPI.shared.tmdbLanguageCodes()
        // Sort the codes by the actual string that will be displayed, not the code itself
        let sortedCodes = codes.sorted { code1, code2 in
            guard let displayString1 = Locale.current.localizedString(forIdentifier: code1) else {
                return false
            }
            guard let displayString2 = Locale.current.localizedString(forIdentifier: code2) else {
                return true
            }
            
            return displayString1.lexicographicallyPrecedes(displayString2)
        }
        // TODO: Executed on correct thread?
        // TODO: Make JFConfig an actor?
        JFConfig.shared.availableLanguages = sortedCodes
        return sortedCodes
    }
    
    /// Downloads an image using the given TMDB image path
    /// - Parameter imagePath: The TMDB image path
    /// - Returns: The downloaded UIImage
    static func loadImage(with imagePath: String, size: Int?) async throws -> UIImage {
        try await loadImage(from: Self.getTMDBImageURL(path: imagePath, size: size))
    }
}

enum UserError: Error {
    case noPro
}

enum HTTPError: Error {
    case invalidResponse
}

enum JFError: Error {
    case decodingError
}

public struct ParentalRating {
    var color: Color?
    var label: String
    
    var symbol: some View {
        Image(systemName: "\(label).square")
            .foregroundColor(color ?? .primary)
    }
    
    init(_ label: String, color: Color? = nil) {
        self.label = label
        self.color = color
    }
}

extension ParentalRating {
    static let fskRatings = [fskNoRestriction, fskAgeSix, fskAgeTwelve, fskAgeSixteen, fskAgeEighteen]
    static let fskNoRestriction: Self = .init("0", color: .init("NoRestriction"))
    static let fskAgeSix: Self = .init("6", color: .init("AgeSix"))
    static let fskAgeTwelve: Self = .init("12", color: .init("AgeTwelve"))
    static let fskAgeSixteen: Self = .init("16", color: .init("AgeSixteen"))
    static let fskAgeEighteen: Self = .init("18", color: .init("AgeEighteen"))
}

/// Returns the smaller non-nil object of the given two objects
/// - Parameters:
///   - x: The first object to compare
///   - y: The second object to compare
/// - Returns: The smaller non-nil object. If both objects are nil, the function returns nil.
func min<T>(_ x: T?, _ y: T?) -> T? where T: Comparable {
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
func max<T>(_ x: T?, _ y: T?) -> T? where T: Comparable {
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
    public var id: Int { self.hashValue }
}

/// Overload of the default NSLocalizedString function that uses an empty comment
public func NSLocalizedString(_ key: String, tableName: String? = nil) -> String {
    NSLocalizedString(key, tableName: tableName, comment: "")
}
