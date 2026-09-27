// Copyright © 2026 Jonas Frey. All rights reserved.

import Foundation

extension DecodingError {
    /// A user-visible diagnostic containing enough context to identify an incompatible payload field.
    var diagnosticDescription: String {
        switch self {
        case .typeMismatch(let expectedType, let context):
            diagnosticDescription(
                caseName: "DecodingError.typeMismatch",
                context: context,
                codingPath: context.codingPath,
                expectedType: expectedType
            )
        case .valueNotFound(let expectedType, let context):
            diagnosticDescription(
                caseName: "DecodingError.valueNotFound",
                context: context,
                codingPath: context.codingPath,
                expectedType: expectedType
            )
        case .keyNotFound(let key, let context):
            diagnosticDescription(
                caseName: "DecodingError.keyNotFound",
                context: context,
                codingPath: context.codingPath + [key],
                missingKey: key.stringValue
            )
        case .dataCorrupted(let context):
            diagnosticDescription(
                caseName: "DecodingError.dataCorrupted",
                context: context,
                codingPath: context.codingPath
            )
        @unknown default:
            String(describing: self)
        }
    }

    /// Builds a consistent diagnostic from a decoding error case and its context.
    /// - Parameters:
    ///   - caseName: The stable Swift case name.
    ///   - context: The decoder-provided failure context.
    ///   - codingPath: The complete path to the incompatible value.
    ///   - expectedType: The type the decoder expected, when available.
    ///   - missingKey: The missing key, when applicable.
    /// - Returns: A multiline diagnostic suitable for logging or display.
    private func diagnosticDescription(
        caseName: String,
        context: DecodingError.Context,
        codingPath: [any CodingKey],
        expectedType: (any Any.Type)? = nil,
        missingKey: String? = nil
    ) -> String {
        var lines = [
            caseName,
            "\(Strings.DecodingError.path): \(Self.pathDescription(codingPath))",
        ]

        if let expectedType {
            lines.append("\(Strings.DecodingError.expectedType): \(String(describing: expectedType))")
        }
        if let missingKey {
            lines.append("\(Strings.DecodingError.missingKey): \(missingKey)")
        }
        lines.append("\(Strings.DecodingError.debugDescription): \(context.debugDescription)")
        if let underlyingError = context.underlyingError {
            lines.append("\(Strings.DecodingError.underlyingError): \(underlyingError.localizedDescription)")
        }
        return lines.joined(separator: "\n")
    }

    /// Formats coding keys as a dot path with bracketed array indexes.
    /// - Parameter codingPath: The coding keys leading to a decoded value.
    /// - Returns: A readable coding path, or a localized root marker for an empty path.
    private static func pathDescription(_ codingPath: [any CodingKey]) -> String {
        let path = codingPath.reduce(into: "") { path, key in
            if let index = key.intValue {
                path += "[\(index)]"
            } else {
                if !path.isEmpty {
                    path += "."
                }
                path += key.stringValue
            }
        }
        return path.isEmpty ? Strings.DecodingError.rootPath : path
    }
}
