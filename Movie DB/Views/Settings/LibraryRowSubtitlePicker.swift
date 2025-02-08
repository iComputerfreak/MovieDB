// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct LibraryRowSubtitlePicker: View {
    @EnvironmentObject private var preferences: JFConfig

    let validOptions: [LibraryRow.SubtitleContent] = [.watchState, .personalRating, .watchDate, .lastModified]

    var body: some View {
        Picker(selection: $preferences.defaultSubtitleContent) {
            ForEach(validOptions, id: \.self) { option in
                Group {
                    switch option {
                    case .watchState:
                        Text(Strings.Settings.defaultSubtitleContentPickerLabelWatchState)
                    case .personalRating:
                        Text(Strings.Settings.defaultSubtitleContentPickerLabelPersonalRating)
                    case .watchDate:
                        Text(Strings.Settings.defaultSubtitleContentPickerLabelWatchDate)
                    case .lastModified:
                        Text(Strings.Settings.defaultSubtitleContentPickerLabelLastModified)
                    default:
                        Text(verbatim: "")
                    }
                }
                .tag(option)
            }
        } label: {
            Text(Strings.Settings.defaultSubtitleContentPickerLabel)
        }
    }
}

#Preview {
    DefaultWatchStatePicker()
}
