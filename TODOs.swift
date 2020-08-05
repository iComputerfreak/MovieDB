//
//  TODOs.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//


// Fixes / Todo soon
/*
 TODO: Re-write API to use proper errors instead of nil-data
 TODO: Export CSV alphabetically
 TODO: Bug: All series show up in "Missing" with missing "watched"
 TODO: When importing, Media.nextID gets increated due to decoding (although the user might discard the data or there is an error)
 TODO: lastEpisodeWatched does not update while in the editing screen
 TODO: Create an option to export the tags
 TODO: Add a Refresh option when swiping an entry to the left (next to delete)
 TODO: Reduce thumbnail file size and only load the full image when accessing it in Detail (currently using 1.4 MB of RAM per image)
 TODO: Go through the code and look at every try? and think about, if we really want to ignore that error
 */

// Future:
/*
 TODO: Re-write documentation for TMDBAPI
 TODO: Check, if all properties and functions are properly documented
 TODO: Set language and region automatically to device defaults (only once on first start)
 TODO: Use the rate limiting response to prevent wasting API requests (do active rate limiting)
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
 */

// Not possible right now (SwiftUI limitations):
/*
 TODO: Add section indices for the media library like in the Contacts app
 TODO: Open a newly created media in Detail and maybe editing mode
 */
