//
//  Strings+Filter.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings.Library {
    enum Filter {
        static let navBarTitle = String(
            localized: "library.filter.navBar.title",
            comment: "The navigation bar title for the library's filter view"
        )
        static let navBarButtonReset = String(
            localized: "library.filter.button.reset",
            comment: "Button label for the reset button in the filter view"
        )
        static let navBarButtonApply = String(
            localized: "library.filter.button.apply",
            comment: "Button label for the apply button in the filter view"
        )
        static let valueAny = String(
            localized: "library.filter.value.any",
            comment: "A string describing that the value of a specific media property does not matter in regards of filtering the library list and that the property may have 'any' value."
        )
        
        // MARK: UserData
        static let userDataSectionHeader = String(
            localized: "detail.userData.header",
            comment: "The section header for the user data section in the detail view"
        )
        static let watchedLabel = String(
            localized: "library.filter.userData.label.watched",
            comment: "The label of the picker in the filter view to select whether the media should be marked as watched or not"
        )
        static let watchedNavBarTitle = String(
            localized: "library.filter.watched.navBar.title",
            comment: "The navigation bar title for the watched? field in the library's filter view"
        )
        static let watchAgainLabel = String(
            localized: "library.filter.userData.label.watchAgain",
            comment: "The label for the 'watch again' picker in the library's filter view"
        )
        static let watchAgainNavBarTitle = String(
            localized: "library.filter.watchAgain.navBar.title",
            comment: "The navigation bar title for the watchAgain? field in the library's filter view"
        )
        static let tagsLabel = String(
            localized: "library.filter.userData.label.tags",
            comment: "The label for the tags picker in the library's filter view"
        )
        
        // MARK: Basic Information
        static let basicInfoSectionHeader = String(
            localized: "detail.information.header",
            comment: "The section header for the information section in the detail view"
        )
        static let mediaTypeLabel = String(
            localized: "library.filter.information.label.mediaType",
            comment: "The label for the 'media type' picker in the library's filter view"
        )
        static let mediaTypeNavBarTitle = String(
            localized: "library.filter.mediaType.navBar.title",
            comment: "The navigation bar title for the media type field in the library's filter view"
        )
        static let genresLabel = String(
            localized: "library.filter.information.label.genres",
            comment: "The label of the genres picker in the library's filter view"
        )
        static let ratingLabel = String(
            localized: "library.filter.information.label.personalRating",
            comment: "The personal rating one assign a media object as a value of 0 to 5 stars"
        )
        static func ratingValueLabel(_ amount: Double) -> String {
            String(
                localized: "library.filter.information.label.rating \(amount)",
                comment: "A star rating from 0 to 5 stars in 0.5 star steps"
            )
        }

        static func ratingValueRangeLabel(_ from: Double, _ to: Double) -> String {
            String(
                localized: "library.filter.information.label.rating.range \(from) \(to)",
                comment: "A range of star ratings, both ranging from 0 to 5 stars in 0.5 star steps"
            )
        }

        static let yearLabel = String(
            localized: "library.filter.information.label.year",
            comment: "The label for the picker for selecting the release year in the library filter view"
        )
        static func yearValueLabel(_ year: Int) -> String {
            String(
                localized: "library.filter.information.label.year \(year)",
                comment: "Year label in the filter settings"
            )
        }

        static func yearValueRangeLabel(_ from: Int, _ to: Int) -> String {
            String(
                localized: "library.filter.information.label.year.range \(String(from)) \(String(to))",
                comment: "Year range label in the filter settings. The first parameter is the lower bound of the range. The second parameter is the upper bound of the range (inclusive)"
            )
        }

        static let mediaStatusLabel = String(
            localized: "library.filter.information.label.status",
            comment: "The label for the status picker in the library's filter view"
        )
        
        // MARK: Show Specific
        static let showSpecificSectionHeader = String(
            localized: "library.filter.showSpecific.header",
            comment: "The heading in the library filter view for the properties that are specific to tv shows"
        )
        static let showTypeLabel = String(
            localized: "library.filter.showSpecific.label.showType",
            comment: "The label for the show type picker in the library's filter view"
        )
        static let seasonsLabel = String(
            localized: "library.filter.showSpecific.label.seasons",
            comment: "The label for the picker in the filter view that lets the user choose the range of number of seasons to filter by"
        )
        static func seasonsValueLabel(_ seasons: Int) -> String {
            String(
                localized: "library.filter.showSpecific.label.seasonCount \(seasons)",
                comment: "The season count label in the filter settings"
            )
        }

        static func seasonsValueRangeLabel(_ from: Int, _ to: Int) -> String {
            String(
                localized: "library.filter.showSpecific.label.seasonCount.range \(from) \(to)",
                comment: "The label for the range of season counts in the filter settings"
            )
        }
        
        static let watchStateWatchedFully = String(
            localized: "library.filter.watchStateWatchedFully",
            comment: "The picker value for a generic watch state of either a movie or a show that indicates that the user has watched this media completely."
        )
        
        static let watchStateWatched = String(
            localized: "library.filter.watchStateWatched",
            comment: "The picker value for a generic watch state of either a movie or a show that indicates that the user has watched this media either completely or partially."
        )
        
        static let watchStateWatchedPartially = String(
            localized: "library.filter.watchStateWatchedPartially",
            comment: "The picker value for a generic watch state of either a movie or a show that indicates that the user has watched this media partially."
        )
        
        static let watchStateNotWatched = String(
            localized: "library.filter.watchStateNotWatched",
            comment: "The picker value for a generic watch state of either a movie or a show that indicates that the user has not watched this media completely."
        )
        
        static let watchStateUnknown = String(
            localized: "library.filter.watchStateUnknown",
            comment: "The picker value for a generic watch state of either a movie or a show that indicates that the watch state of this media is unknown."
        )
    }
}
