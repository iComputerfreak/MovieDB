// Copyright © 2023 Jonas Frey. All rights reserved.

import SwiftUI

private struct IsEditingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isEditing: Bool {
        get { self[IsEditingKey.self] }
        set { self[IsEditingKey.self] = newValue }
    }
}
