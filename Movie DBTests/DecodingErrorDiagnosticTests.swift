// Copyright © 2026 Jonas Frey. All rights reserved.

@testable import Movie_DB
import Foundation
import Testing

@Suite("Decoding error diagnostics")
struct DecodingErrorDiagnosticTests {
    @Test("Type mismatch includes case, path, expected type, and actual payload type")
    func describesTypeMismatch() throws {
        let error = try decodingError(for: #"{"release_dates":{"id":42}}"#, as: Response.self)

        #expect(error.diagnosticDescription.contains("DecodingError.typeMismatch"))
        #expect(error.diagnosticDescription.contains("release_dates.id"))
        #expect(error.diagnosticDescription.contains("Array<Any>"))
        #expect(error.diagnosticDescription.contains("found number"))
    }

    @Test("Coding path formats array indexes")
    func formatsArrayIndexes() throws {
        let error = try decodingError(
            for: #"{"release_dates":[{"id":[]},{"id":42}]}"#,
            as: ArrayResponse.self
        )

        #expect(error.diagnosticDescription.contains("release_dates[1].id"))
    }

    @Test("Missing key path includes the absent key")
    func includesMissingKeyInPath() throws {
        let error = try decodingError(for: #"{"release_dates":{}}"#, as: Response.self)

        #expect(error.diagnosticDescription.contains("DecodingError.keyNotFound"))
        #expect(error.diagnosticDescription.contains("release_dates.id"))
    }

    /// Decodes a deliberately incompatible payload and returns its decoding error.
    /// - Parameters:
    ///   - json: The malformed payload to decode.
    ///   - type: The response type to decode.
    /// - Returns: The resulting decoding error.
    /// - Throws: A test failure when decoding succeeds or throws another error type.
    private func decodingError<T: Decodable>(for json: String, as type: T.Type) throws -> DecodingError {
        do {
            _ = try JSONDecoder().decode(type, from: Data(json.utf8))
            Issue.record("Expected decoding to fail")
            throw UnexpectedError()
        } catch let error as DecodingError {
            return error
        }
    }

    private struct Response: Decodable {
        let releaseDates: ReleaseDates

        private enum CodingKeys: String, CodingKey {
            case releaseDates = "release_dates"
        }
    }

    private struct ReleaseDates: Decodable {
        let id: [Int]
    }

    private struct ArrayResponse: Decodable {
        let releaseDates: [ReleaseDates]

        private enum CodingKeys: String, CodingKey {
            case releaseDates = "release_dates"
        }
    }

    private struct UnexpectedError: Error {}
}
