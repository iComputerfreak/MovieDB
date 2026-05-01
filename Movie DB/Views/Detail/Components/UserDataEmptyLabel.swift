// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct UserDataEmptyLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .italic()
            .foregroundStyle(.secondary)
    }
}
