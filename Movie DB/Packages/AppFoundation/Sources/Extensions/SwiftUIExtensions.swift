// Copyright © 2026 Jonas Frey. All rights reserved.

import SwiftUI

public extension ButtonRole {
    static var legacyConfirm: Self? {
        if #available(iOS 26.0, *) {
            return .confirm
        } else {
            return nil
        }
    }

    static var legacyClose: Self? {
        if #available(iOS 26.0, *) {
            return .close
        } else {
            return nil
        }
    }
}
