//
//  Utils.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import CoreData
import Foundation
import JFUtils
import os.log
import StoreKit
import SwiftUI
import UIKit

struct Utils {
    /// The URL describing the documents directory of the app
    static var documentsPath: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private init() {}
    
    /// Executes an HTTP request with the given URL
    /// - Parameter url: The URL to request
    /// - Returns: The data and URLResponse
    static func request(from url: URL, session: URLSession = .shared) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        Logger.network.info("Making GET Request to \(request.url?.absoluteString ?? "nil", privacy: .private)")
        #if DEBUG
            // In Debug mode, always load the URL, never use the cache
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        #endif
        return try await session.data(for: request)
    }
    
    /// Returns an URL describing the directory with the given name in the documents directory and creates it, if neccessary
    /// - Parameter directory: The name of the folder in the documents directory
    static func url(for directory: String) -> URL? {
        guard let url = documentsPath?.appendingPathComponent(directory) else { return nil }
        // Create the directory, if it not already exists
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Logger.fileSystem.error("Error creating folder in documents directory: \(error, privacy: .public)")
        }
        return url
    }
    
    static func imagesDirectory() -> URL? {
        url(for: "images")
    }
    
    static func imageFileURL(path imagePath: String) -> URL? {
        // The image path already contains the jpg extension
        imagesDirectory()?.appendingPathComponent(imagePath)
    }
    
    static func imageFileURL(for mediaID: UUID) -> URL? {
        imagesDirectory()?.appendingPathComponent(mediaID.uuidString.appending(".jpg"))
    }
    
    /// Returns either black or white, depending on the color scheme
    /// - Parameter colorScheme: The current color scheme environment variable
    static func primaryUIColor(_ colorScheme: ColorScheme) -> UIColor {
        colorScheme == .light ? .black : .white
    }
    
    /// Removes the local image for the given media ID
    static func deleteImage(for mediaID: UUID) throws {
        if
            let fileURL = imageFileURL(for: mediaID),
            FileManager.default.fileExists(atPath: fileURL.path())
        {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
    
    /// Downloads an image using the given URL
    /// - Parameter url: The URL to download the image from
    /// - Returns: The downloaded UIImage
    static func loadImage(from url: URL) async throws -> UIImage {
        Logger.network.info("Loading image from \(url.absoluteString, privacy: .public)")
        let (data, response) = try await Self.request(from: url)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299) ~= httpResponse.statusCode
        else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let dataString = String(data: data, encoding: .utf8)
            Logger.network.error(
                // swiftlint:disable:next line_length
                "statusCode should be 2xx, but is \(statusCode?.description ?? "nil")). Response: \(response, privacy: .public). Data: \(dataString ?? "nil", privacy: .public)"
            )
            throw HTTPError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            throw JFError.decodingError
        }
        
        return image
    }
    
    /// Returns a closed range containing the years of all media objects in the library
    static func yearBounds(context: NSManagedObjectContext) -> ClosedRange<Int> {
        let minShow = fetchMinMaxShow(key: Schema.Show.firstAirDate, ascending: true, context: context)
        let minMovie = fetchMinMaxMovie(key: Schema.Movie.releaseDate, ascending: true, context: context)
        let maxShow = fetchMinMaxShow(key: Schema.Show.firstAirDate, ascending: false, context: context)
        let maxMovie = fetchMinMaxMovie(key: Schema.Movie.releaseDate, ascending: false, context: context)
        
        let currentYear = Calendar.current.dateComponents([.year], from: Date()).year!
        let lowerBound: Int = min(minShow?.year, minMovie?.year) ?? currentYear
        let upperBound: Int = max(maxShow?.year, maxMovie?.year) ?? currentYear
        
        assert(lowerBound <= upperBound, "The fetch request returned wrong results. " +
            "Try inverting the ascending/descending order of the fetch requests")
        
        return lowerBound...upperBound
    }
    
    /// Returns a closed range containing the season counts from all media objects in the library
    static func numberOfSeasonsBounds(context: NSManagedObjectContext) -> ClosedRange<Int> {
        let min = fetchMinMaxShow(key: Schema.Show.numberOfSeasons, ascending: true, context: context)
        let max = fetchMinMaxShow(key: Schema.Show.numberOfSeasons, ascending: false, context: context)
        
        if min?.numberOfSeasons == nil {
            return 0...(max?.numberOfSeasons ?? 0)
        }
        return min!.numberOfSeasons!...(max?.numberOfSeasons ?? min!.numberOfSeasons!)
    }
    
    /// Returns a list of all genres existing in the viewContext, sorted by name and not including duplicates.
    static func allGenres(context: NSManagedObjectContext) -> [Genre] {
        allObjects(entityName: Schema.Genre._entityName, context: context)
            .removingDuplicates(key: \.id)
            .sorted(on: \.name, by: <)
    }

    /// Returns a list of all watch providers existing in the viewContext, sorted by name and not including duplicates.
    static func allNonBuyWatchProviders(context: NSManagedObjectContext) -> [WatchProvider] {
        allObjects(entityName: Schema.WatchProvider._entityName, context: context)
            .removingDuplicates(key: \.id)
            .filter(where: \.type, isNotEqualTo: .buy)
            .sorted(on: \.name, by: <)
    }

    /// Returns a list of all media objects existing in the viewContext.
    static func allMedias(context: NSManagedObjectContext) -> [Media] {
        allObjects(entityName: Schema.Media._entityName, context: context)
            .removingDuplicates(key: \.id)
            .sorted(on: \.id, by: <)
    }
    
    /// Returns a list of all entities with the given name in the given context.
    static func allObjects<T: NSManagedObject>(entityName: String, context: NSManagedObjectContext) -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
        let objects = try? context.fetch(fetchRequest)
        return objects ?? []
    }
    
    private static func fetchMinMaxMovie(
        key: Schema.Movie,
        ascending: Bool,
        context: NSManagedObjectContext
    ) -> Movie? {
        fetchMinMax(fetchRequest: Movie.fetchRequest(), key: key.rawValue, ascending: ascending, context: context)
    }
    
    private static func fetchMinMaxShow(key: Schema.Show, ascending: Bool, context: NSManagedObjectContext) -> Show? {
        fetchMinMax(fetchRequest: Show.fetchRequest(), key: key.rawValue, ascending: ascending, context: context)
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
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                guard let source = scene.windows.last?.rootViewController else { return }
                let vc = UIActivityViewController(
                    activityItems: items,
                    applicationActivities: nil
                )
                vc.excludedActivityTypes = excludedActivityTypes
                vc.popoverPresentationController?.sourceView = source.view
                vc.popoverPresentationController?.sourceRect = source.view.bounds
                vc.popoverPresentationController?.permittedArrowDirections = .any
                source.present(vc, animated: true)
            }
        }
    }
    
    /// Returns the human readable language name from the given locale string consisting of an ISO-639-1 language string and possibly an ISO-3166-1 region string
    ///
    ///     languageString("pt-BR") // Returns "Portuguese (Brazil)"
    ///     languageString("de") // Returns "German"
    static func languageString(for code: String, locale: Locale = Locale.current) -> String? {
        locale.localizedString(forIdentifier: code)
    }
    
    /// Maps a parental rating certification label to a color
    /// Supports only ratings with a `countryCode` of "DE" or "US"
    static func parentalRatingColor(
        for country: String,
        label: String,
        in context: NSManagedObjectContext
    ) -> UIColor? {
        // swiftlint:disable switch_case_on_newline
        switch country.uppercased() {
            // Germany: FSK Ratings
        case "DE":
            switch label {
            case "0": return UIColor.noRestriction
            case "6": return UIColor.ageSix
            case "12": return UIColor.ageTwelve
            case "16": return UIColor.ageSixteen
            case "18": return UIColor.ageEighteen
            default: return nil
            }
        case "US":
            switch label {
            case "NR": return UIColor.usMovieNR
            case "G": return UIColor.usMovieG
            case "PG": return UIColor.usMoviePG
            case "PG-13": return UIColor.usMoviePG13
            case "R": return UIColor.usMovieR
            case "NC-17": return UIColor.usMovieNC17
            default: return nil
            }
        default:
            return nil
        }
        // swiftlint:enable switch_case_on_newline
    }
}

// MARK: - TMDB
extension Utils {
    /// The list of TMDB image paths to not download
    static var posterDenyList = UserDefaults.standard.array(forKey: JFLiterals.Keys.posterDenyList) as? [String] ?? []
    
    /// The `DateFormatter` for translating to and from TMDB date representation (using the UTC time zone)
    static var tmdbUTCDateFormatter: DateFormatter = createTMDBDateFormatter(in: .utc)
    /// The `DateFormatter` for translating to and from TMDB date representation (using the current time zone)
    static var tmdbCurrentDateFormatter: DateFormatter = createTMDBDateFormatter(in: .current)
    
    private static func createTMDBDateFormatter(in timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    /// Builds the URL for an TMDB image
    /// - Parameters:
    ///   - path: The path of the image
    ///   - size: The size of the image. Must be a size supported by the TMDB API
    static func getTMDBImageURL(path: String, size: Int?) -> URL? {
        // Don't load images on the deny list (should be checked before calling this function and replace with a placeholder image)
        guard !posterDenyList.contains(path) else {
            Logger.network.warning("Poster path \(path, privacy: .public) is on deny list. Denying url fetch.")
            assertionFailure(
                "This should have been prevented from being called for poster paths on the deny list " +
                "in the first place."
            )
            return nil
        }
        let sizeString = size != nil ? "w\(size!)" : "original"
        return URL(string: "https://image.tmdb.org/t/p/\(sizeString)/\(path)")
    }
    
    @discardableResult
    static func updateTMDBLanguages() async throws -> [String] {
        let codes = try await TMDBAPI.shared.tmdbLanguageCodes()
        // Sort the codes by the actual string that will be displayed, not the code itself
        let sortedCodes = codes.sorted { code1, code2 in
            guard let displayString1 = Locale.current.localizedString(forIdentifier: code1) else { return false }
            guard let displayString2 = Locale.current.localizedString(forIdentifier: code2) else { return true }
            
            return displayString1.lexicographicallyPrecedes(displayString2)
        }
        await MainActor.run {
            JFConfig.shared.availableLanguages = sortedCodes
        }
        return sortedCodes
    }
    
    /// Downloads an image using the given TMDB image path
    /// - Parameter imagePath: The TMDB image path
    /// - Returns: The downloaded UIImage
    static func loadImage(with imagePath: String, size: Int?) async throws -> UIImage? {
        if let url = getTMDBImageURL(path: imagePath, size: size) {
            return try await loadImage(from: url)
        }
        return nil
    }
}

enum UserError: LocalizedError {
    case noPro
    case mediaAlreadyAdded
    
    var errorDescription: String? {
        switch self {
        case .noPro:
            Strings.UserError.noPro
        case .mediaAlreadyAdded:
            Strings.UserError.mediaAlreadyAdded
        }
    }
}

enum HTTPError: Error {
    case invalidResponse
}

enum JFError: Error {
    case decodingError
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
extension Array: @retroactive Identifiable where Element: Hashable {
    public var id: Int { hashValue }
}
