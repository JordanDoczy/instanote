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
        List {
            ForEach(viewModel.notes) { note in
                NoteRow(note: note, searchText: $viewModel.searchText)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.onSelect(note)
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .background(LinearGradient(.darker, .dark).ignoresSafeArea())
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
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
                    Text(note.captionText)
                        .font(.body)
                        .foregroundStyle(.white)
                        .tint(.white)
                        .lineLimit(3)
                        // Tapping a hashtag searches for it instead of opening a URL.
                        .environment(\.openURL, OpenURLAction { url in
                            searchText = url.absoluteString
                            return .handled
                        })
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
    NavigationStack {
        NoteListView(viewModel: .init(service: MockNoteService()))
    }
    .preferredColorScheme(.dark)
}
