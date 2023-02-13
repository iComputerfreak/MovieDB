//
//  UserInfo.swift
//  Movie DB
//
//  Created by Jonas Frey on 25.11.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import SwiftUI

// TODO: Move into separate file
private struct IsEditingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isEditing: Bool {
        get { self[IsEditingKey.self] }
        set { self[IsEditingKey.self] = newValue }
    }
}

/// Represents the user data section in the ``MediaDetail`` view
struct UserData: View {
    @EnvironmentObject private var mediaObject: Media
    @Environment(\.isEditing) private var isEditing
    
    var body: some View {
        if self.mediaObject.isFault {
            EmptyView()
        } else {
            Section(
                header: HStack {
                    Image(systemName: "person.fill")
                    Text(Strings.Detail.userDataSectionHeader)
                }
            ) {
                // MARK: Rating
                RatingView(rating: $mediaObject.personalRating)
                    .headline(Strings.Detail.personalRatingHeadline)
                // MARK: Watched field
                if mediaObject.type == .movie {
                    SimpleValueView<MovieWatchState?>(
                        values: MovieWatchState.allCases + [nil],
                        value: .init(
                            // swiftlint:disable force_cast
                            get: { (self.mediaObject as! Movie).watched },
                            set: { (self.mediaObject as! Movie).watched = $0 }
                            // swiftlint:enable force_cast
                        ),
                        label: { state in
                            if let state {
                                switch state {
                                case .watched:
                                    return Strings.Detail.watchedPickerValueYes
                                case .partially:
                                    return Strings.Detail.watchedPickerValuePartially
                                case .notWatched:
                                    return Strings.Detail.watchedPickerValueNo
                                }
                            }
                            return "-"
                        }
                    )
                    .headline(Strings.Detail.watchedHeadline)
                } else {
                    // Has watched show field
                    // swiftlint:disable force_cast
                    WatchedShowView(
                        watched: .init(
                            get: { (mediaObject as! Show).watched },
                            set: { (mediaObject as! Show).watched = $0 }
                        ),
                        maxSeason: (mediaObject as! Show).numberOfSeasons
                    )
                    // swiftlint:enable force_cast
                }
                // MARK: Watch again field
                SimpleValueView<Bool>.createYesNo(value: $mediaObject.watchAgain)
                    .headline(Strings.Detail.watchAgainHeadline)
                // MARK: Taglist
                TagListView($mediaObject.tags)
                // MARK: Notes
                if !mediaObject.notes.isEmpty || isEditing {
                    NotesView($mediaObject.notes)
                }
            }
        }
    }
}

struct UserData_Previews: PreviewProvider {
    static var previews: some View {
        List {
            UserData()
                .environmentObject(PlaceholderData.movie as Media)
            UserData()
                .environmentObject(PlaceholderData.movie as Media)
                .environment(\.isEditing, true)
        }
        .previewDisplayName("Movie")
        
        List {
            UserData()
                .environmentObject(PlaceholderData.show as Media)
            UserData()
                .environmentObject(PlaceholderData.show as Media)
                .environment(\.isEditing, true)
        }
        .previewDisplayName("Show")
    }
}
