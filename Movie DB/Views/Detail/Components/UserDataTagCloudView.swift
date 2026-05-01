// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

struct UserDataTagCloudView: View {
    let tags: Set<Tag>

    var body: some View {
        if tags.isEmpty {
            UserDataEmptyLabel(text: Strings.Detail.noTagsLabel)
        } else {
            WrappingHStack {
                ForEach(Array(tags).sorted(on: \.name, by: <), id: \.objectID) { tag in
                    CapsuleLabelView(text: tag.name)
                }
            }
        }
    }
}
