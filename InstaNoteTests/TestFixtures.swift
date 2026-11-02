//
//  TestFixtures.swift
//  InstaNoteTests
//

import CoreLocation
import UIKit
@testable import instanote

enum TestFixtures {

    static let coordinate = CLLocationCoordinate2D(latitude: 37.7619920, longitude: -122.4347360)

    /// Stands in for the real location lookup so tests never show the permission prompt.
    static func noLocation() async -> CLLocationCoordinate2D? { nil }

    /// A solid-color image. `orientation` lets tests mimic camera photos whose pixels are stored sideways.
    static func image(width: CGFloat, height: CGFloat, orientation: UIImage.Orientation = .up) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { context in
            UIColor.systemPink.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        return UIImage(cgImage: image.cgImage!, scale: 1, orientation: orientation)
    }

    /// A service backed by an in-memory store, so tests never touch the user's notes.
    static func makeService() -> NoteService {
        NoteService(container: Persistence.makeInMemoryContainer())
    }

    /// Deletes every note, which also removes any photo files the test wrote to Documents.
    static func removeAllNotes(from service: NoteService) {
        service.deleteAll()
        service.save()
    }
}
