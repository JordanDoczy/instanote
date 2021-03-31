//
//  NoteListView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI
import Combine

struct NoteListView: View {

    @StateObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            LinearGradient(.darker, .dark)
                .ignoresSafeArea(edges: .all)
            VStack {
                SearchBar(text: $viewModel.searchText)
                List {
                    ForEach(viewModel.notes) { note in
                        NoteRow(viewModel: .init(note: note, searchText: $viewModel.searchText))
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                            .onTapGesture {
                                viewModel.selectedNote = note
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
    class ViewModel: ObservableObject {
        @Published var notes: [Note] = []
        @Published var searchText: String = "" {
            didSet {
                filter(by: searchText)
            }
        }
        @Binding var selectedNote: Note?

        private let service: NoteService
        private var subscriber: AnyCancellable? = nil

        init(service: NoteService, selectedNote: Binding<Note?>) {
            self.service = service
            self._selectedNote = selectedNote
            
            subscriber = service.publisher.sink { [weak self] notes in
                self?.notes = notes
            }
        }

        func filter(by searchText: String) {
            notes = service.filter(by: searchText)
        }
    }
}

extension NoteListView {
    
    struct NoteRow: View {

        class ViewModel: ObservableObject {
            @Published var imagePath: String? = nil
            @Published var caption: NSAttributedString = NSAttributedString()
            @Published var subtitle: String = ""
            @Binding var searchText: String
            
            init(note: Note, searchText: Binding<String>) {
                self._searchText = searchText
                imagePath = note.imagePath
                caption = note.captionFormatted ?? NSAttributedString()
                subtitle = note.subtitle ?? ""
            }
        }
        
        @StateObject var viewModel: ViewModel
        
        var body: some View {
            
            ZStack (alignment: .bottomLeading) {
                if let imagePath = viewModel.imagePath {
                    ImageView(with: imagePath)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .animation(.none)
                }
                
                VStack (alignment: .leading) {
                    Text(viewModel.subtitle)
                        .font(Font.subheadline.bold()).padding([.top,.bottom], 1).foregroundColor(.white)
                    TextView(text: $viewModel.caption, selectedText: $viewModel.searchText)
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

struct NoteListView_Previews: PreviewProvider {

    static var previews: some View {
        NoteListView(viewModel: .init(service: MockNoteService(),
                                      selectedNote: .constant(nil)))
    }
}
