// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI
import UIKit

struct SeasonInfoRowView: View {
    @State var season: Season
    @Binding var thumbnail: UIImage??

    var body: some View {
        HStack {
            // swiftlint:disable:next redundant_nil_coalescing
            Image(uiImage: thumbnail ?? nil, defaultImage: JFLiterals.posterPlaceholderName)
                .thumbnail()

            VStack(alignment: .leading) {
                Text(season.name)
                    .bold()

                if let airDate = season.airDate {
                    Text(airDate.formatted(date: .numeric, time: .omitted))
                        .italic()
                }

                Text(Strings.Detail.seasonsInfoEpisodeCount(season.episodeCount))
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    List {
        SeasonInfoRowView(
            season: PlaceholderData.preview.staticShow.seasons.sorted(on: \.seasonNumber, by: <).first!,
            thumbnail: .constant(nil)
        )
    }
    .previewEnvironment()
}
