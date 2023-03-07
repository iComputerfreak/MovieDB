//
//  Environment.swift
//  Movie DB
//
//  Created by Jonas Frey on 07.03.23.
//  Copyright © 2023 Jonas Frey. All rights reserved.
//

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
