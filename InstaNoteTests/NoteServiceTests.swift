//
//  NoteServiceTests.swift
//  InstaNoteTests
//

import CoreLocation
import Foundation
import Testing
@testable import instanote

struct NoteServiceTests {

    @Test func notesAtTheSameCoordinateShareOneLocation() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }

        _ = service.createNote(caption: "first", uiImage: TestFixtures.image(width: 4, height: 4), location: TestFixtures.coordinate)
        _ = service.createNote(caption: "second", uiImage: TestFixtures.image(width: 4, height: 4), location: TestFixtures.coordinate)
        service.save()

        #expect(service.getLocations().count == 1)
    }

    @Test func getLocationFindsAnExistingCoordinate() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }

        _ = service.createNote(caption: "note", uiImage: TestFixtures.image(width: 4, height: 4), location: TestFixtures.coordinate)
        service.save()

        #expect(service.getLocation(TestFixtures.coordinate) != nil)
    }

    @Test func searchResultsAreNewestFirst() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }

        let captions = ["#beach one", "#beach two", "#beach three", "#beach four"]
        for (index, caption) in captions.enumerated() {
            let note = service.createNote(caption: caption, uiImage: TestFixtures.image(width: 4, height: 4))
            note.date = Date(timeIntervalSince1970: TimeInterval(index * 1_000))
        }
        service.save()

        let results = service.filter(by: "#beach").map(\.caption)

        #expect(results == ["#beach four", "#beach three", "#beach two", "#beach one"])
    }

    @Test func searchMatchesCaptionPrefixAndTagsWithoutDuplicates() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }

        _ = service.createNote(caption: "beach day #beach", uiImage: TestFixtures.image(width: 4, height: 4))
        _ = service.createNote(caption: "sunset #beach", uiImage: TestFixtures.image(width: 4, height: 4))
        _ = service.createNote(caption: "city #downtown", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()

        let results = Set(service.filter(by: "beach").compactMap(\.caption))

        #expect(results == ["beach day #beach", "sunset #beach"])
    }
}
