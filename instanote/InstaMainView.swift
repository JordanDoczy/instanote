//
//  InstaMainView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct InstaMainView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            NoteListView(viewModel: .init(service: viewModel.service, selectedNote: $viewModel.selectedNote))
                .sheet(isPresented: $viewModel.isPresented) {
                    viewModel.selectedNote = nil
                } content: {
                    EditNoteView(viewModel: .init(service: viewModel.service, note: viewModel.selectedNote))
                }
            Button { // create new note button
                viewModel.selectedNote = nil // for new notes, selectedNote will be empty
                viewModel.isPresented = true // force the sheet to present
            } label: {
                Image(systemName: "plus")
                    .frame(width: 75, height: 75)
                    .font(Font.system(size: 25).bold())
                    .foregroundColor(.darker)
                    .background(Color.primaryColor)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .shadow(color: .darker, radius: 2, x: 2, y: 2)
                    .shadow(color: .primaryColorLight, radius: 2, x: -2, y: -2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

extension InstaMainView {
    class ViewModel: ObservableObject {
        var service: NoteService

        @Published var isPresented: Bool = false
        
        /// When a note is selected from the `NoteListView` we toggle `isPresented` to `true` to present the note
        @Published var selectedNote: Note? = nil {
            didSet {
                isPresented = selectedNote != nil
            }
        }
        
        init(service: NoteService) {
            self.service = service
        }
    }
}

struct InstaMainView_Previews: PreviewProvider {

    static let service = MockNoteService()

    static var previews: some View {
        InstaMainView(viewModel: .init(service: service))
    }
}
