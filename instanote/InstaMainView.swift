//
//  InstaMainView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import CoreLocation
import Observation
import SwiftUI

struct InstaMainView: View {

    @Bindable var viewModel: ViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                NoteListView(viewModel: viewModel.noteList)
            }
            .sheet(item: $viewModel.editor) { editor in
                EditNoteView(viewModel: editor)
            }
            Button { // create new note button
                viewModel.edit(nil)
            } label: {
                Image(systemName: "plus")
                    .font(Font.system(size: 25).bold())
                    .foregroundStyle(Color.darker)
                    .frame(width: 75, height: 75)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(.primaryColor).interactive(), in: .circle)
            .accessibilityLabel("New Note")
        }
        // The app's palette is dark, so system controls (search field, sheets) should match.
        .preferredColorScheme(.dark)
    }
}

extension InstaMainView {

    @Observable
    final class ViewModel {
        let noteList: NoteListView.ViewModel

        /// The note being created or edited. Setting it presents the editor; the sheet clears it on dismiss.
        var editor: EditNoteView.ViewModel?

        private let service: NoteService
        private let currentLocation: () async -> CLLocationCoordinate2D?

        init(service: NoteService,
             currentLocation: @escaping () async -> CLLocationCoordinate2D? = CurrentLocation.coordinate) {
            self.service = service
            self.currentLocation = currentLocation
            self.noteList = NoteListView.ViewModel(service: service)
            noteList.onSelect = { [weak self] note in
                self?.edit(note)
            }
        }

        /// Opens the editor for `note`, or for a new note when `note` is nil.
        func edit(_ note: Note?) {
            editor = EditNoteView.ViewModel(service: service, note: note, currentLocation: currentLocation)
        }
    }
}

#Preview {
    InstaMainView(viewModel: .init(service: MockNoteService()))
}
