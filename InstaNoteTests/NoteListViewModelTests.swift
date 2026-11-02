//
//  NoteListViewModelTests.swift
//  InstaNoteTests
//

import Foundation
import Testing
@testable import instanote

struct NoteListViewModelTests {

    @Test func showsAllNotesNewestFirstWhenNotSearching() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        let older = service.createNote(caption: "older", uiImage: TestFixtures.image(width: 4, height: 4))
        older.date = .distantPast
        _ = service.createNote(caption: "newer", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()

        let viewModel = NoteListView.ViewModel(service: service)

        #expect(viewModel.notes.compactMap(\.caption) == ["newer", "older"])
    }

    @Test func searchStaysAppliedWhenNotesChange() {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        _ = service.createNote(caption: "#beach day", uiImage: TestFixtures.image(width: 4, height: 4))
        _ = service.createNote(caption: "#city night", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()

        let viewModel = NoteListView.ViewModel(service: service)
        viewModel.searchText = "beach"

        _ = service.createNote(caption: "#mountain hike", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()

        #expect(viewModel.notes.compactMap(\.caption) == ["#beach day"])
    }
}
