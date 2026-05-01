// Copyright © 2022 Jonas Frey. All rights reserved.

import Foundation

public enum MovieWatchState: String, WatchState, CaseIterable {
    case watched
    case partially
    case notWatched
}
