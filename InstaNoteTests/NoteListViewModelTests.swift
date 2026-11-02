//
//  NoteListViewModelTests.swift
//  InstaNoteTests
//

import SwiftUI
import Testing
@testable import instanote

struct NoteListViewModelTests {

    @Test func searchStaysAppliedWhenNotesChange() async {
        let service = TestFixtures.makeService()
        defer { TestFixtures.removeAllNotes(from: service) }
        _ = service.createNote(caption: "#beach day", uiImage: TestFixtures.image(width: 4, height: 4))
        _ = service.createNote(caption: "#city night", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()

        let viewModel = NoteListView.ViewModel(service: service, selectedNote: .constant(nil))
        viewModel.searchText = "beach"

        // Any save makes the service publish the full list again.
        _ = service.createNote(caption: "#mountain hike", uiImage: TestFixtures.image(width: 4, height: 4))
        service.save()
        await drainMainQueue()

        #expect(viewModel.notes.compactMap(\.caption) == ["#beach day"])
    }

    /// The view model receives updates with `receive(on: DispatchQueue.main)`. The main queue is
    /// FIFO, so once a block queued after that delivery runs, the delivery has run too.
    private func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }
}
