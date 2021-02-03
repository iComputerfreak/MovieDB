//
//  TODOs.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//


// Fixes / Todo soon
/*
 TODO: lastEpisodeWatched does not update while in the editing screen
 TODO: Add a Refresh option when swiping an entry to the left (next to delete)
 TODO: Reduce thumbnail file size and only load the full image when accessing it in Detail (currently using 1.4 MB of RAM per image)
 TODO: Add option to load more search results (like a "Load more..." button)
 TODO: Make multiPageRequest parallel
 TODO: Update does not show progress bar
 TODO: Group Im-/Exports together
 TODO: Add Sort button and change Filter to filter symbol
 */

// Future:
/*
 TODO: Show where to watch: https://developers.themoviedb.org/3/movies/get-movie-watch-providers
 TODO: Set language and region automatically to device defaults (only once on first start)
 TODO: Hide Search Bar when scrolling down
 TODO: Lookup Tab
 TODO: Fetch parental rating from TMDB using /movie/{movie_id}/release_dates or /tv/{tv_id}/content_ratings and show them as small icons below the name in the list
 TODO: Can the thumbnail file on disk be deleted without causing any problems? (only on macOS)
 TODO: Information messages when no internet available / information could not be loaded (cast pictures, etc.)
 TODO: Add more filters (e.g. Original Language)
 TODO: iCloud Sync
 TODO: Maybe add a status "watched partially" for movies and seasons
 TODO: Show if new episodes are available for series you watched (only works if I can get the Netflix, Prime, Sky, ... data)
 TODO: Add the option to favorite some movies/shows
 TOOD: Add the option to reset collection IDs, so every show and movie gets a fresh ID starting at 1 in alphabetical order
 TODO: Maybe decode created_by of shows to show the show creators in the details
 TODO: Add more ratings (Rotten Tomatoes, IMDB, Google?, Metacritic)
 */

// Not possible right now (SwiftUI limitations):
/*
 TODO: Add section indices for the media library like in the Contacts app
 TODO: Open a newly created media in Detail and maybe editing mode
 */



// CloudKit Integration
/*
 
 Media records in CloudKit
 - thumbnail as Asset (reduced size)
 - Full cover only loaded when clicking it
 - Cast photos only loaded when clicking cast
 
 
 - Store UserData + Information in records
 - Maybe don't store cast/seasons at all? Always load when requested?
 
 Save in Private DB, not Public
 
 https://www.toptal.com/ios/sync-data-across-devices-with-cloudkit
 https://medium.com/apple-developer-academy-federico-ii/syncing-data-on-ios-devices-with-coredata-and-cloudkit-bed296fc26e0
 https://www.raywenderlich.com/4878052-cloudkit-tutorial-getting-started
 https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/MaintainingaLocalCacheofCloudKitRecords/MaintainingaLocalCacheofCloudKitRecords.html#//apple_ref/doc/uid/TP40014987-CH12-SW1
 
 - Handling, wenn Benutzer Daten in iCloud über Einstellungen löscht
 - networkUnavailable errors handeln
 - network operations neu versuchen, sobald Netzwerk wieder erreichbar
 
 
 https://developer.apple.com/videos/play/wwdc2016/231/
 
 */
