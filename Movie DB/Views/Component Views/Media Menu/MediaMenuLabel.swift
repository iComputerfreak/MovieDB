// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

struct MediaMenuLabel: View {
    var body: some View {
        Label(Strings.Detail.mediaMenuLabel, systemImage: "ellipsis.circle")
    }
}

#Preview {
    MediaMenuLabel()
}
