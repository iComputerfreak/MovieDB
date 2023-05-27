//
//  Strings+Detail.swift
//  Movie DB
//
//  Created by Jonas Frey on 23.05.22.
//  Copyright © 2022 Jonas Frey. All rights reserved.
//

extension Strings {
    enum Detail {
        static let navBarErrorTitle = String(
            localized: "detail.navBar.errorTitle",
            comment: "The navigation bar title for the detail view when an error occured during loading"
        )
        static let errorLoadingText = String(
            localized: "detail.errorLoadingText",
            comment: "The text displayed in the detail view when the media object to display could not be loaded"
        )
        
        // MARK: Toolbar
        static let menuButtonFavorite = String(
            localized: "detail.menu.favorite",
            comment: "The 'favorite' action in the media menu that lets the user mark a media as favorite."
        )
        static let menuButtonUnfavorite = String(
            localized: "detail.menu.unfavorite",
            comment: "The 'unfavorite' action in the media menu that lets the user mark a media as not favorite anymore."
        )
        static let menuButtonAddToWatchlist = String(
            localized: "detail.menu.addToWatchlist",
            comment: "The 'add to watchlist' media action that adds a media object to the user's watchlist"
        )
        static let menuButtonRemoveFromWatchlist = String(
            localized: "detail.menu.removeFromWatchlist",
            comment: "The 'remove from watchlist' media action that removes a media object from the user's watchlist"
        )
        
        // MARK: UserData
        static let userDataSectionHeader = String(
            localized: "detail.userData.header",
            comment: "The section header for the user data section in the detail view"
        )
        static let personalRatingHeadline = String(
            localized: "detail.userData.headline.personalRating",
            comment: "The headline for the 'personal rating' property in the detail view"
        )
        static let watchedHeadline = String(
            localized: "detail.userData.headline.watched",
            comment: "The headline for the 'watched' property in the detail view"
        )
        static let watchedPickerValueYes = String(
            localized: "detail.userData.watched.picker.watched",
            comment: "The picker value of the detail view's user data section which the user chooses if they watched the media object"
        )
        static let watchedPickerValuePartially = String(
            localized: "detail.userData.watched.picker.partiallyWatched",
            comment: "The picker value of the detail view's user data section which the user chooses if they watched the media object partially"
        )
        static let watchedPickerValueNo = String(
            localized: "detail.userData.watched.picker.notWatched",
            comment: "The picker value of the detail view's user data section which the user chooses if they did not watch the media object"
        )
        static let watchAgainHeadline = String(
            localized: "detail.userData.headline.watchAgain",
            comment: "The headline for the 'watch again' property in the detail view"
        )
        static let tagsHeadline = String(
            localized: "detail.userData.headline.tags",
            comment: "The headline for the 'tags' property in the detail view"
        )
        static let notesHeadline = String(
            localized: "detail.userData.headline.notes",
            comment: "The headline for the 'notes' property in the detail view"
        )
        static let watchedShowLabelUnknown = String(
            localized: "detail.userData.watchedShow.label.unknown",
            comment: "The label in the detail view describing that it is unknown whether the user has watched the show"
        )
        static let watchedShowLabelNo = String(
            localized: "detail.userData.watchedShow.label.no",
            comment: "The label in the detail view describing that the user has not watched the show"
        )
        static func watchedShowLabelSeason(_ season: Int) -> String {
            String(
                localized: "detail.userData.watchedShow.label.season \(season)",
                comment: "The label in the detail view describing that the user has watched up to a specific season of the show. The parameter is the season number."
            )
        }

        static func watchedShowLabelSeasonEpisode(_ season: Int, _ episode: Int) -> String {
            String(
                localized: "detail.userData.watchedShow.label.seasonAndEpisode \(season) \(episode)",
                comment: "The label in the detail view describing that the user has watched up to a specific episode of a season of the show. The first parameter is the season number. The second parameter is the episode number."
            )
        }

        static let watchedShowEditingHeader = String(
            localized: "detail.userData.watchedShow.header",
            comment: "The header in the editing view where the user specifies up to which season/episode they watched."
        )
        static func watchedShowEditingLabelSeason(_ season: Int) -> String {
            String(
                localized: "detail.userData.watchedShow.label.seasonNumber \(season)",
                comment: "The label of the picker in the detail view where the user specifies up to which season they watched. Label specifies the season number. The parameter is the season number."
            )
        }

        static func watchedShowEditingLabelEpisode(_ episode: Int) -> String {
            String(
                localized: "detail.userData.watchedShow.label.episodeNumber \(episode)",
                comment: "The label of the picker in the detail view where the user specifies up to which episode they watched. Label specifies the episode number. The parameter is the episode number."
            )
        }

        static let watchedShowEditingLabelNotWatched = String(
            localized: "detail.userData.watchedShow.label.notWatched",
            comment: "The label of the picker in the detail view where the user specifies up to which season they watched. Label specifies that the user did not watch the show."
        )
        static let watchedShowEditingLabelAllEpisodes = String(
            localized: "detail.userData.watchedShow.label.allEpisodes",
            comment: "The label of the picker in the detail view where the user specifies up to which episode they watched. Label specifies that the user watched all episodes of the season."
        )
        static let watchedShowEditingLabelUnknown = String(
            localized: "detail.userData.watchedShow.label.unknown",
            comment: "The label of the picker in the detail view where the user specifies up to which episode they watched. Label specifies that the watch state of the show is unknown."
        )
        static let noTagsLabel = String(
            localized: "detail.userData.tags.none",
            comment: "The label of the tag list in the user data section of the detail view specifying that there are no tags for this media."
        )
        static func tagsFooter(_ count: Int) -> String {
            String(
                localized: "detail.tags.footer \(count)",
                comment: "The total number of tags, displayed as a footer beneath the list"
            )
        }

        static let tagsNavBarTitle = String(
            localized: "detail.tags.navBar.title",
            comment: "The navigation bar title for the tags in the detail view"
        )
        static let noNotesLabel = String(
            localized: "detail.userData.noNotes",
            comment: "Label in the detail view of a media object that describes the absence of any user-provided notes."
        )
        static let notesNavBarTitle = String(
            localized: "detail.notes.navBar.title",
            comment: "The navigation bar title for the notes in the detail view"
        )
        static let seasonsInfoNavBarTitle = String(
            localized: "detail.seasonsInfo.navBar.title",
            comment: "The navigation bar title for the seasons info in the detail view"
        )
        static func seasonsInfoEpisodeCount(_ count: Int) -> String {
            String(
                localized: "detail.extendedInfo.seasons.episodeCount \(count)",
                comment: "A string describing how many episodes a season has"
            )
        }

        // MARK: Basic Information
        static let basicInfoSectionHeader = String(
            localized: "detail.basicInfo.header",
            comment: "The section header for the basic information section in the detail view"
        )
        static let genresHeadline = String(
            localized: "detail.basicInfo.headline.genres",
            comment: "The headline for the 'genres' property in the detail view"
        )
        static let descriptionHeadline = String(
            localized: "detail.basicInfo.headline.description",
            comment: "The headline for the 'description' property in the detail view"
        )
        static let releaseDateHeadline = String(
            localized: "detail.basicInfo.headline.releaseDate",
            comment: "The headline for the 'release date' property in the detail view"
        )
        static let runtimeHeadline = String(
            localized: "detail.basicInfo.headline.runtime",
            comment: "The headline for the 'runtime' property in the detail view"
        )
        static func runtimeValueLabel(_ minutes: String, _ hours: String) -> String {
            String(
                localized: "detail.basicInfo.runtime.minutesAndHours \(minutes) \(hours)",
                comment: "A string that displays a formatted duration in minutes and hours/minutes. E.g. '90 minutes (1h 30m)'. The first parameter is the formatted duration string in minutes. The second parameter is the formatted duration string in hours and minutes."
            )
        }

        static let firstAiredHeadline = String(
            localized: "detail.basicInfo.headline.firstAired",
            comment: "The headline for the 'first aired' property in the detail view"
        )
        static let lastEpisodeHeadline = String(
            localized: "detail.basicInfo.headline.lastEpisode",
            comment: "The headline for the 'last episode' property in the detail view"
        )
        static let lastAiredHeadline = String(
            localized: "detail.basicInfo.headline.lastAired",
            comment: "The headline for the 'last aired' property in the detail view"
        )
        static let nextEpisodeHeadline = String(
            localized: "detail.basicInfo.headline.nextEpisode",
            comment: "The headline for the 'next episode' property in the detail view"
        )
        static let showTypeHeadline = String(
            localized: "detail.basicInfo.headline.showType",
            comment: "The headline for the 'show type' property in the detail view"
        )
        static let mediaStatusHeadline = String(
            localized: "detail.basicInfo.headline.status",
            comment: "The headline for the 'status' property in the detail view"
        )
        static let originalTitleHeadline = String(
            localized: "detail.basicInfo.headline.originalTitle",
            comment: "The headline for the 'original title' property in the detail view"
        )
        static let originalLanguageHeadline = String(
            localized: "detail.basicInfo.headline.originalLanguage",
            comment: "The headline for the 'original language' property in the detail view"
        )
        static let productionCountriesHeadline = String(
            localized: "detail.basicInfo.headline.productionCountries",
            comment: "The headline for the 'production countries' property in the detail view"
        )
        static let seasonsHeadline = String(
            localized: "detail.basicInfo.headline.seasons",
            comment: "The headline for the 'seasons' property in the detail view"
        )
        static func seasonCountLabel(_ seasons: Int) -> String {
            String(
                localized: "detail.basicInfo.seasonCount \(seasons)",
                comment: "A string that describes the number of seasons of a tv show in the media detail"
            )
        }

        static let castLabel = String(
            localized: "detail.basicInfo.cast",
            comment: "The button label in the detail of a media object that leads to the cast information."
        )
        
        static func castMemberRole(_ roleName: String) -> String {
            String(
                localized: "detail.cast.roleNameLabel \(roleName)",
                comment: "The label text that describes the role a cast member fulfills. The parameter is the role name."
            )
        }
        
        static func episodeAirDateWithDate(_ season: Int, _ episode: Int, _ date: String) -> String {
            String(
                localized: "detail.episodeAirDate \(season) \(episode) \(date)",
                comment: "Season/Episode abbreviation for the 'next/last episode to air' field, including the date. First argument: season number, second argument: episode number, third argument: formatted date"
            )
        }

        static func episodeAirDate(_ season: Int, _ episode: Int) -> String {
            String(
                localized: "detail.episodeAirDate \(season) \(episode)",
                comment: "Season/Episode abbreviation for the 'next/last episode to air' field, without a date. First argument: season number, second argument: episode number"
            )
        }
        
        // MARK: Watch Providers
        static let watchProvidersSectionHeader = String(
            localized: "detail.watchProviders.label",
            comment: "The label/heading of the watch providers panel in the media detail"
        )
        static let watchProvidersAttribution = String(
            localized: "detail.watchProviders.attribution",
            comment: "Attribution below the watch providers panel that attributes the source of the data to JustWatch.com"
        )
        
        // MARK: Extended Information
        static let extendedInfoSectionHeader = String(
            localized: "detail.extendedInfo.header",
            comment: "The section header for the extended information section in the detail view"
        )
        static let taglineHeadline = String(
            localized: "detail.extendedInfo.headline.tagline",
            comment: "The headline for the 'tagline' property in the detail view"
        )
        static let budgetHeadline = String(
            localized: "detail.extendedInfo.headline.budget",
            comment: "The headline for the 'budget' property in the detail view"
        )
        static let revenueHeadline = String(
            localized: "detail.extendedInfo.headline.revenue",
            comment: "The headline for the 'revenue' property in the detail view"
        )
        static let tmdbIDHeadline = String(
            localized: "detail.extendedInfo.headline.tmdbID",
            comment: "The headline for the 'tmdb id' property in the detail view"
        )
        static let imdbIDHeadline = String(
            localized: "detail.extendedInfo.headline.imdbID",
            comment: "The headline for the 'imdb id' property in the detail view"
        )
        static let homepageHeadline = String(
            localized: "detail.extendedInfo.headline.homepage",
            comment: "The headline for the 'homepage' property in the detail view"
        )
        static let productionCompaniesHeadline = String(
            localized: "detail.extendedInfo.headline.productionCompanies",
            comment: "The headline for the 'production companies' property in the detail view"
        )
        static let networksHeadline = String(
            localized: "detail.extendedInfo.headline.networks",
            comment: "The headline for the 'networks' property in the detail view"
        )
        static let createdByHeadline = String(
            localized: "detail.extendedInfo.headline.createdBy",
            comment: "The headline for the 'created by' property in the detail view"
        )
        static let popularityHeadline = String(
            localized: "detail.extendedInfo.headline.popularity",
            comment: "The headline for the 'popularity' property in the detail view"
        )
        static let scoringHeadline = String(
            localized: "detail.extendedInfo.headline.scoring",
            comment: "The headline for the 'scoring' property in the detail view"
        )
        static func scoringValueLabel(_ avg: Double, _ max: Double, _ count: Int) -> String {
            String(
                localized: "detail.extendedInfo.scoring \(avg) \(max) \(count)",
                comment: "A string describing the average rating of a media object on TMDb. The first parameter is the average score/rating (0-10) as a decimal number. The second parameter is the maximum score a media object can achieve (10) as a decimal number. The third argument is the number of votes that resulted in this score."
            )
        }
        
        static let mediaMenuLabel = String(
            localized: "detail.mediaMenu.label",
            comment: "The (invisible) label for the media menu that shows actions to be performed on a single media object."
        )
        
        // MARK: Metadata
        static let metadataSectionHeader = String(
            localized: "detail.metadata.header",
            comment: "The section header for the metadata section in the detail view"
        )
        static let internalIDHeadline = String(
            localized: "detail.metadata.headline.internalID",
            comment: "The headline for the 'internal id' property in the detail view"
        )
        static let createdHeadline = String(
            localized: "detail.metadata.headline.created",
            comment: "The headline for the 'creation date' property in the detail view"
        )
        static let lastModifiedHeadline = String(
            localized: "detail.metadata.headline.lastModified",
            comment: "The headline for the 'last modified' property in the detail view"
        )
        
        // MARK: - Notifications
        static let addedToListNotificationTitle = String(
            localized: "detail.notification.addedToList.title",
            comment: "The title of the notification popup that is displayed when a media object has been added to a list"
        )
        
        static func addedToListNotificationMessage(_ listName: String) -> String {
            String(
                localized: "detail.notification.addedToList.message \(listName)",
                comment: "The subtitle/message of the notification popup that is displayed when a media object has been added to a list. The parameter is the list name."
            )
        }
        
        static let reloadCompleteNotificationTitle = String(
            localized: "detail.notification.reloadComplete.title",
            comment: "The title of the notification popup that is displayed when a single media object has been reloaded by the user"
        )
        
        enum Alert {
            static let newTagTitle = String(
                localized: "detail.alert.newTag.title",
                comment: "Title of an alert for adding a new tag"
            )
            static let newTagMessage = String(
                localized: "detail.alert.newTag.message",
                comment: "Text of an alert for adding a new tag"
            )
            static let newTagButtonAdd = String(
                localized: "detail.alert.newTag.button.add",
                comment: "Button of an alert to confirm adding a new tag"
            )
            static let tagAlreadyExistsTitle = String(
                localized: "detail.alert.tagAlreadyExists.title",
                comment: "Message of an alert informing the user that the tag they tried to create already exists"
            )
            static let tagAlreadyExistsMessage = String(
                localized: "detail.alert.tagAlreadyExists.message",
                comment: "Message of an alert informing the user that the tag they tried to create already exists"
            )
            static let renameTagTitle = String(
                localized: "detail.alert.renameTag.title",
                comment: "Title of the tag renaming alert"
            )
            static let renameTagMessage = String(
                localized: "detail.alert.renameTag.message",
                comment: "Message of the tag renaming alert"
            )
            static let renameTagButtonRename = String(
                localized: "detail.alert.renameTag.button.rename",
                comment: "Rename button to confirm renaming a tag"
            )
            static let errorLoadingCastTitle = String(
                localized: "detail.alert.errorLoadingCastTitle",
                comment: "The title of an alert informing the user about an error while loading the cast information"
            )
        }
    }
}
