// Copyright © 2025 Jonas Frey. All rights reserved.

import SwiftUI

struct ProblemsLabel: View {
    let problems: [String]

    var body: some View {
        Group {
            Text(Strings.Problems.missingListPrefix)
            + Text(verbatim: " ")
            + Text(problems.joined(separator: ", ")).italic()
        }
        .font(.caption)
    }
}

#Preview {
    ProblemsLabel(problems: ["Problem 1", "Problem 2"])
}
