//
//  NoteListView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Observation
import SwiftUI

struct NoteListView: View {

    @Bindable var viewModel: ViewModel

    var body: some View {
        ZStack {
            LinearGradient(.darker, .dark)
                .ignoresSafeArea(edges: .all)
            VStack {
                SearchBar(text: $viewModel.searchText)
                List {
                    ForEach(viewModel.notes) { note in
                        NoteRow(note: note, searchText: $viewModel.searchText)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                            .onTapGesture {
                                viewModel.onSelect(note)
                            }
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension NoteListView {

    @Observable
    final class ViewModel {
        var searchText: String = ""

        /// Called when the user taps a note.
        @ObservationIgnored
        var onSelect: (Note) -> Void = { _ in }

        private let service: NoteService

        init(service: NoteService) {
            self.service = service
        }

        /// Reads `service.notes` even while searching, so results refresh whenever notes change.
        var notes: [Note] {
            let allNotes = service.notes
            return searchText.isEmpty ? allNotes : service.filter(by: searchText)
        }
    }
}

extension NoteListView {

    struct NoteRow: View {

        // NSManagedObject publishes its own changes, so edits to a note redraw its row.
        @ObservedObject var note: Note
        @Binding var searchText: String

        var body: some View {
            ZStack (alignment: .bottomLeading) {
                if let imagePath = note.imagePath {
                    ImageView(with: imagePath)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .transaction { $0.animation = nil }
                }

                VStack (alignment: .leading) {
                    Text(note.subtitle ?? "")
                        .font(Font.subheadline.bold()).padding([.top,.bottom], 1).foregroundColor(.white)
                    TextView(text: note.captionFormatted ?? NSAttributedString(), selectedText: $searchText)
                        .frame(maxHeight: 75) // TODO: remove fixed height, needs to be dynamic
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                .padding(.top, 50)
                .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                                           startPoint: .top,
                                           endPoint: .bottom))
            }
        }
    }
}

#Preview {
    NoteListView(viewModel: .init(service: MockNoteService()))
}
