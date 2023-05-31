//
//  PredicateMediaList+Problems.swift
//  Movie DB
//
//  Created by Jonas Frey on 30.05.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import Foundation

extension PredicateMediaList {
    /// A media list that shows medias with problems (i.e. missing information)
    static let problems = PredicateMediaList(
        name: Strings.Lists.defaultListNameProblems,
        description: Strings.Lists.problemsDescription,
        iconName: "exclamationmark.triangle.fill",
        // This predicate looks for movies or shows that are incomplete / have problems
        predicate: NSCompoundPredicate(type: .and, subpredicates: [
            // To be included, the movie/show must not be marked as "not watched"
            NSCompoundPredicate(type: .or, subpredicates: [
                // We don't include movies that are marked as 'not watched'
                // type == .movie && (watched == nil || watched != .notWatched)
                NSPredicate(
                    format: "%K = %@ AND (%K = nil OR %K != %@)",
                    Schema.Media.type.rawValue,
                    MediaType.movie.rawValue,
                    Schema.Movie.watchedState.rawValue,
                    Schema.Movie.watchedState.rawValue,
                    MovieWatchState.notWatched.rawValue
                ),
                // We don't include shows that are marked as explicitly 'not watched'
                // type == .show && !(show.notWatched)
                NSCompoundPredicate(type: .and, subpredicates: [
                    NSPredicate(
                        format: "%K = %@",
                        Schema.Media.type,
                        MediaType.show.rawValue
                    ),
                    ShowWatchState.showsNotWatchedPredicate.negated(),
                ]),
            ]),
            // If any of these applies, information is missing
            NSCompoundPredicate(type: .or, subpredicates: [
                // Personal Rating missing
                NSPredicate(
                    // personalRating == nil || personalRating == .noRating
                    format: "%K = nil OR %K = %lld",
                    Schema.Media.personalRating.rawValue,
                    Schema.Media.personalRating.rawValue,
                    StarRating.noRating.rawValue
                ),
                // WatchAgain missing
                NSPredicate(format: "%K = nil", Schema.Media.watchAgain),
                // Tags missing
                NSPredicate(format: "tags.@count = 0"),
                // Watched missing (Movie)
                NSPredicate(
                    format: "%K = %@ AND %K = nil",
                    Schema.Media.type,
                    MediaType.movie.rawValue,
                    Schema.Movie.watchedState
                ),
                // Last watched missing (Show)
                ShowWatchState.showsWatchedUnknownPredicate,
            ]),
        ])
    )
}
