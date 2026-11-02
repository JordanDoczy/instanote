//
//  EditNoteViewModelTests.swift
//  InstaNoteTests
//

import Foundation
import Testing
@testable import instanote

struct EditNoteViewModelTests {

    @Test func editingANoteWithAPhotoShowsThePhoto() throws {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        let note = service.createNote(caption: "hello", uiImage: TestFixtures.image(width: 4, height: 4), location: TestFixtures.coordinate)
        service.save()

        let viewModel = EditNoteView.ViewModel(service: service, note: note, currentLocation: TestFixtures.noLocation)

        #expect(viewModel.hasImage)
        guard case .picture(.some) = viewModel.state else {
            Issue.record("Expected the photo to be shown, got \(viewModel.state)")
            return
        }
    }

    @Test func savingWithoutChangingThePhotoKeepsTheSameFile() throws {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        let note = service.createNote(caption: "hello", uiImage: TestFixtures.image(width: 4, height: 4), location: TestFixtures.coordinate)
        service.save()
        let originalPhoto = try #require(note.photo)

        let viewModel = EditNoteView.ViewModel(service: service, note: note, currentLocation: TestFixtures.noLocation)
        viewModel.caption = "hello again"
        viewModel.save()

        #expect(note.photo == originalPhoto)
        #expect(note.caption == "hello again")
    }

    @Test func savingANewPhotoReplacesTheFile() throws {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        let note = service.createNote(caption: "hello", uiImage: TestFixtures.image(width: 4, height: 4), location: TestFixtures.coordinate)
        service.save()
        let originalPhoto = try #require(note.photo)

        let viewModel = EditNoteView.ViewModel(service: service, note: note, currentLocation: TestFixtures.noLocation)
        viewModel.uiImage = TestFixtures.image(width: 8, height: 8)
        viewModel.save()

        #expect(note.photo != originalPhoto)
    }

    @Test func placeholderCaptionIsNotSaved() throws {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }

        let viewModel = EditNoteView.ViewModel(service: service, location: TestFixtures.coordinate)
        viewModel.uiImage = TestFixtures.image(width: 4, height: 4)
        viewModel.save()

        let note = try #require(service.getNotes()?.first)
        #expect(note.caption != EditNoteView.Constants.defaultText)
    }

    @Test func noteWithoutALocationIsNotPlacedAtZeroZero() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        let note = service.createNote(caption: "no location", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()

        let viewModel = EditNoteView.ViewModel(service: service, note: note, currentLocation: TestFixtures.noLocation)

        #expect(viewModel.location == nil)
    }

    @Test func captionLongerThanTheLimitIsRejected() {
        let viewModel = EditNoteView.ViewModel(service: TestFixtures.makeService(), caption: "short", location: TestFixtures.coordinate)

        viewModel.caption = String(repeating: "a", count: EditNoteView.Constants.maxCaptionCharacterCount + 1)

        #expect(viewModel.caption == "short")
    }

    @Test func typingAHashtagSuggestsMatchingTags() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        _ = service.createNote(caption: "#beach #beachday #city", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()
        let viewModel = EditNoteView.ViewModel(service: service, caption: "", location: TestFixtures.coordinate)

        type("fun at the #bea", into: viewModel)

        #expect(Set(viewModel.tags) == ["beach", "beachday"])
    }

    @Test func choosingASuggestionCompletesTheHashtag() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        _ = service.createNote(caption: "#beachday", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()
        let viewModel = EditNoteView.ViewModel(service: service, caption: "", location: TestFixtures.coordinate)

        type("fun at the #bea", into: viewModel)
        viewModel.updateTag(tag: "beachday")

        #expect(viewModel.caption == "fun at the #beachday")
    }

    /// Enters text one character at a time, the way the text editor reports keystrokes.
    private func type(_ text: String, into viewModel: EditNoteView.ViewModel) {
        for character in text {
            viewModel.caption += String(character)
        }
    }
}
