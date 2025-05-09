// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct SubtitleContentPicker: View {
    private let validOptions: [LibraryRow.SubtitleContent] = [
        .nothing,
        .watchState,
        .personalRating,
        .watchDate,
        .lastModified,
        .flatrateWatchProviders
    ]

    @Binding var subtitleContent: LibraryRow.SubtitleContent?
    let showsUseDefaultOption: Bool

    init(subtitleContent: Binding<LibraryRow.SubtitleContent?>, showsUseDefaultOption: Bool = false) {
        self._subtitleContent = subtitleContent
        self.showsUseDefaultOption = showsUseDefaultOption
    }

    var body: some View {
        Picker(selection: $subtitleContent) {
            if showsUseDefaultOption {
                // TODO: Localize
                Text("Use Default")
                    .tag(nil as LibraryRow.SubtitleContent?)
            }
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
                    case .nothing:
                        Text(Strings.Settings.defaultSubtitleContentPickerLabelNothing)
                    case .flatrateWatchProviders:
                        Text(Strings.Settings.defaultSubtitleContentPickerLabelWatchProviders)
                    case .problems:
                        // Not a valid option defined above
                        Text(verbatim: "")
                    }
                }
                .tag(option as LibraryRow.SubtitleContent?)
            }
        } label: {
            Text(Strings.Settings.defaultSubtitleContentPickerLabel)
        }
    }
}

#Preview {
    SubtitleContentPicker(subtitleContent: .constant(.watchState))
}
