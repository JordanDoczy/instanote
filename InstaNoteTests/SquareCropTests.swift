//
//  SquareCropTests.swift
//  InstaNoteTests
//

import Testing
import UIKit
@testable import instanote

struct SquareCropTests {

    @Test func cropsToTheShortestSide() {
        let image = TestFixtures.image(width: 300, height: 200)

        let cropped = image.squareCropped(maxPixelSide: 2048)

        #expect(cropped.size == CGSize(width: 200, height: 200))
    }

    @Test func scalesDownLargePhotos() {
        let image = TestFixtures.image(width: 4032, height: 3024)

        let cropped = image.squareCropped(maxPixelSide: 2048)

        #expect(cropped.size == CGSize(width: 2048, height: 2048))
        #expect(cropped.scale == 1)
    }

    @Test func resultIsUprightForSidewaysCameraPhotos() {
        // Camera photos taken in portrait store landscape pixels with a `.right` orientation.
        let image = TestFixtures.image(width: 400, height: 300, orientation: .right)

        let cropped = image.squareCropped(maxPixelSide: 2048)

        #expect(cropped.imageOrientation == .up)
        #expect(cropped.size == CGSize(width: 300, height: 300))
    }
}
