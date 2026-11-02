//
//  HashtagTests.swift
//  InstaNoteTests
//

import Foundation
import Testing
@testable import instanote

struct HashtagTests {

    @Test func findsTagNamesWithoutTheHash() {
        #expect("Lunch at #memphis #bbq, #food!".hashtagNames == ["memphis", "bbq", "food"])
    }

    @Test func treatsRepeatedHashesAsOneTag() {
        #expect("##sunsets".hashtagNames == ["sunsets"])
    }

    @Test func ignoresALoneHash() {
        #expect("number # 5".hashtagNames.isEmpty)
    }

    @Test func savingANoteCreatesItsTags() throws {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }

        _ = service.createNote(caption: "Castro theatre #sanfrancisco #movies", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()

        let names = Set(service.getTags().compactMap(\.name))
        #expect(names == ["sanfrancisco", "movies"])
    }

    @Test func captionTextLinksEachHashtag() throws {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        let note = service.createNote(caption: "Candy #sweets #color", uiImage: TestFixtures.image(width: 4, height: 4))

        let links = note.captionText.runs.compactMap { $0.link?.absoluteString }

        #expect(links == ["#sweets", "#color"])
        #expect(String(note.captionText.characters) == "Candy #sweets #color")
    }
}
