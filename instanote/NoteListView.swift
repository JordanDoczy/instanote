//
//  NoteListView2.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI

struct NoteListView: View {

    @ObservedObject var service: RealNoteService
    @Binding var selectedNote: Note?
    @State private var searchText = ""

    var body: some View {
        ZStack {
            LinearGradient(.darker, .dark)
                .ignoresSafeArea(edges: .all)
            VStack {
                SearchBar(text: $searchText)
                List {
                    ForEach(service.notes) { note in
                        NoteRow(model: NoteRow.NoteRowModel(note: note), searchText: $searchText)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                            .onTapGesture {
                                selectedNote = note
                            }
                    }
                }
            }
        }
        .onChange(of: searchText) { _ in
            service.requestNotes(with: searchText)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    struct NoteRow: View {
        
        class NoteRowModel: ObservableObject {
            @Published var imagePath: String? = nil
            @Published var caption: NSAttributedString = NSAttributedString()
            @Published var subtitle: String = ""
            
            convenience init(note: Note) {
                self.init()
                imagePath = note.imagePath
                caption = note.captionFormatted ?? NSAttributedString()
                subtitle = note.subtitle ?? ""
            }
        }
        
        @ObservedObject var model: NoteRowModel
        @Binding var searchText: String
        
        var body: some View {
            
            ZStack (alignment: .bottomLeading) {
                LinearGradient(gradient:
                                Gradient(colors: [Color.primaryColorLight, Color.primaryColor]),
                               startPoint: .top, endPoint: .bottom)
                if let imagePath = model.imagePath {
                    ImageView(with: imagePath)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .animation(.none)
                }
                
                VStack (alignment: .leading) {
                    Text(model.subtitle)
                        .font(Font.subheadline.bold()).padding([.top,.bottom], 1).foregroundColor(.white)
                    TextView(text: $model.caption, selectedText: $searchText)
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
    
    static let service = MockNoteService()
    
    static var previews: some View {
        NoteListView(service: service, selectedNote: .constant(service.notes.first!))
    }
}
