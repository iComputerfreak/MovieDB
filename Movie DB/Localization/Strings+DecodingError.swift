// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

extension Strings {
    /// Provides localized labels for technical decoding diagnostics.
    enum DecodingError {
        static let path = String(
            localized: "decodingError.path",
            defaultValue: "Path",
            comment: "Label for the coding path in a technical decoding error diagnostic."
        )
        static let expectedType = String(
            localized: "decodingError.expectedType",
            defaultValue: "Expected type",
            comment: "Label for the expected Swift type in a technical decoding error diagnostic."
        )
        static let missingKey = String(
            localized: "decodingError.missingKey",
            defaultValue: "Missing key",
            comment: "Label for a missing payload key in a technical decoding error diagnostic."
        )
        static let debugDescription = String(
            localized: "decodingError.debugDescription",
            defaultValue: "Debug description",
            comment: "Label for decoder-provided technical details in a decoding error diagnostic."
        )
        static let underlyingError = String(
            localized: "decodingError.underlyingError",
            defaultValue: "Underlying error",
            comment: "Label for an underlying error in a technical decoding error diagnostic."
        )
        static let rootPath = String(
            localized: "decodingError.rootPath",
            defaultValue: "<root>",
            comment: "Coding path shown when a technical decoding error occurs at the root payload value."
        )
    }
}
