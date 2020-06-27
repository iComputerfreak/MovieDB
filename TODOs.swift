//
//  TODOs.swift
//  Movie DB
//
//  Created by Jonas Frey on 17.12.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

// Fixes / Todo soon
/*
 TODO: Search result years are different from the actual year shown in the library
 TODO: Activity Indicator or Progress bar between import and alert
 TODO: Add a description for the tags (just in a text file for myself)
 TODO: Add headers for each letter and add them to the scroll bar like in the Contacts app
 TODO: Create new tags when importing and maybe create an option to export the tags
 TODO: Add a Refresh option when swiping an entry to the left (next to delete)
 TODO: Add a button in the Details to reload the thumbnail
 TODO: Sometimes a thumbnail goes missing, if the init(from:) function detects a nil thumbnail from disk, it should re-download it
 */

// Future:
/*
 TODO: Look into append_to_response: https://developers.themoviedb.org/3/getting-started/append-to-response
 TODO: Fetch parental rating from TMDB using /movie/{movie_id}/release_dates or /tv/{tv_id}/content_ratings and show them as small icons below the name in the list
 TODO: Can the thumbnail file on disk be deleted without causing any problems?
 TODO: Information messages when no internet available / information could not be loaded (cast pictures, etc.)
 TODO: Add more filters (e.g. Original Language)
 TODO: iCloud Sync
 TODO: Maybe cleanup once in a while (remove all thumbnails where the media id doesn't exist anymore, remove invalid tags from movies
 TODO: Maybe add a status "watched partially" for movies
 TODO: Use the AlertHandler in all views
 TODO: Show if new episodes are available for series you watched (only works if I can get the Netflix, Prime, Sky, ... data)
 TODO: Add the option to favorite some movies/shows
 TOOD: Add the option to reset collection IDs, so every show and movie gets a fresh ID starting at 0 in alphabetical order
 */
