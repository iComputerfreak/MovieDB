// Copyright © 2026 Jonas Frey. All rights reserved.

@testable import Movie_DB
import UIKit
import XCTest

final class TMDBImageServiceTests: XCTestCase {
    func testPosterCacheUsesCachesDirectory() throws {
        let imageDirectory = try XCTUnwrap(Utils.imagesDirectory())
        let cachesDirectory = try XCTUnwrap(Utils.cachesPath)
        let documentsDirectory = try XCTUnwrap(Utils.documentsPath)

        XCTAssertTrue(imageDirectory.path().hasPrefix(cachesDirectory.path()))
        XCTAssertFalse(imageDirectory.path().hasPrefix(documentsDirectory.path()))
    }

    func testDecodeImageDownsamplesToMaximumPixelSize() throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1_000, height: 1_500))
        let sourceImage = renderer.image { context in
            UIColor.red.setFill()
            context.cgContext.fill(CGRect(x: 0, y: 0, width: 1_000, height: 1_500))
        }
        let data = try XCTUnwrap(sourceImage.jpegData(compressionQuality: 0.8))

        let image = try XCTUnwrap(TMDBImageService.decodeImage(data, maxPixelSize: 240))
        let cgImage = try XCTUnwrap(image.cgImage)

        XCTAssertLessThanOrEqual(max(cgImage.width, cgImage.height), 240)
        XCTAssertGreaterThan(max(cgImage.width, cgImage.height), 0)
    }
}
