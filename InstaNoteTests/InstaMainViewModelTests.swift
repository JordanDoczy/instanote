//
//  InstaMainViewModelTests.swift
//  InstaNoteTests
//

import Foundation
import Testing
@testable import instanote

struct InstaMainViewModelTests {

    @Test func tappingANoteOpensItInTheEditor() throws {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        let note = service.createNote(caption: "tap me", uiImage: TestFixtures.image(width: 4, height: 4), location: TestFixtures.coordinate)
        service.save()
        let viewModel = InstaMainView.ViewModel(service: service)

        viewModel.noteList.onSelect(note)

        let editor = try #require(viewModel.editor)
        #expect(editor.title == "Edit Note")
        #expect(editor.caption == "tap me")
    }

    @Test func plusButtonOpensANewNote() throws {
        let viewModel = InstaMainView.ViewModel(service: TestFixtures.makeService())

        viewModel.edit(nil)

        let editor = try #require(viewModel.editor)
        #expect(editor.title == "Create Note")
    }
}
