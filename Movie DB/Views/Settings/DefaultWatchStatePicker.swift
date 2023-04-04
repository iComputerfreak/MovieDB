//
//  DefaultWatchStatePicker.swift
//  Movie DB
//
//  Created by Jonas Frey on 02.04.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

import SwiftUI

struct DefaultWatchStatePicker: View {
    @EnvironmentObject private var preferences: JFConfig
    
    let validOptions: [GenericWatchState] = [.unknown, .watched, .notWatched]
    
    var body: some View {
        Picker(selection: $preferences.defaultWatchState) {
            ForEach(validOptions, id: \.rawValue) { option in
                Group {
                    switch option {
                    case .unknown:
                        Text(Strings.Settings.defaultWatchStatePickerLabelUnknown)
                    case .watched:
                        Text(Strings.Settings.defaultWatchStatePickerLabelWatched)
                    case .notWatched:
                        Text(Strings.Settings.defaultWatchStatePickerLabelNotWatched)
                    case .partiallyWatched:
                        Text(Strings.Settings.defaultWatchStatePickerLabelPartiallyWatched)
                    }
                }
                .tag(option)
            }
        } label: {
            Text(Strings.Settings.defaultWatchStatePickerLabel)
        }
    }
}

struct NewMediaWatchStatePicker_Previews: PreviewProvider {
    static var previews: some View {
        DefaultWatchStatePicker()
    }
}

enum GenericWatchState: String, CaseIterable, Codable {
    case unknown
    case watched
    case partiallyWatched
    case notWatched
}
