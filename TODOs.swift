//
//  TODOs.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

// Fix in experimental, before merging:
/*
 TODO: Change initializer and coding of Season from rawAirDate to airDate
 TODO: Re-write CSV Im-/Export
 TODO: Create Tag Export
 */


// Fixes / Todo soon
/*
 TODO: lastEpisodeWatched does not update while in the editing screen
 TODO: Create an option to export the tags
 TODO: Add a Refresh option when swiping an entry to the left (next to delete)
 TODO: Reduce thumbnail file size and only load the full image when accessing it in Detail (currently using 1.4 MB of RAM per image)
 */

// Future:
/*
 TODO: Look into append_to_response: https://developers.themoviedb.org/3/getting-started/append-to-response
 TODO: Use the rate limiting response to prevent wasting API requests (do active rate limiting)
 TODO: Hide Search Bar when scrolling down
 TODO: Lookup Tab
 TODO: Fetch parental rating from TMDB using /movie/{movie_id}/release_dates or /tv/{tv_id}/content_ratings and show them as small icons below the name in the list
 TODO: Can the thumbnail file on disk be deleted without causing any problems?
 TODO: Information messages when no internet available / information could not be loaded (cast pictures, etc.)
 TODO: Add more filters (e.g. Original Language)
 TODO: iCloud Sync
 TODO: Maybe cleanup once in a while (remove all thumbnails where the media id doesn't exist anymore, remove invalid tags from movies
 TODO: Maybe add a status "watched partially" for movies
 TODO: Show if new episodes are available for series you watched (only works if I can get the Netflix, Prime, Sky, ... data)
 TODO: Add the option to favorite some movies/shows
 TOOD: Add the option to reset collection IDs, so every show and movie gets a fresh ID starting at 0 in alphabetical order
 TODO: Should probably write some unit tests
 TODO: Maybe decode created_by of shows to show the show creators in the details
 */

// Not possible right now (SwiftUI limitations):
/*
 TODO: Add section indices for the media library like in the Contacts app
 TODO: Open a newly created media in Detail and maybe editing mode
 */