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

    @ObservedObject var service: RealNoteService
    @State private var isPresented: Bool = false
    @State private var selectedNote: Note? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NoteListView(service: service, selectedNote: $selectedNote)
            .sheet(isPresented: $isPresented) {
                EditNoteView(viewModel: EditNoteView.EditNoteViewModel(service: service, note: selectedNote))
            }
            Button { // create new note button
                selectedNote = nil // for new notes, selectedNote will be empty
                isPresented = true // force the sheet to present
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
        
        /// State Management: we have two properties that control state: `isPresented` and `selectedNote`
        /// `isPresented` controls the presentation of the sheet
        /// `selectedNote` controls which note to present
        /// We monitor both, this is due to the fact that `onChange` will only occur when the value of `selectedNote` changes
        /// When a note is selected from the `NoteListView` we toggle `isPresented` to `true` to present the note
        /// When `isPresented` is set to `false` we set `selectedNote` to `nil`to allow the user to click on that item again
        
        .onChange(of: selectedNote) { _ in
            isPresented = selectedNote != nil
        }
        .onChange(of: isPresented) { _ in
            selectedNote = isPresented ? selectedNote : nil
        }
    }
}

struct InstaMainView_Previews: PreviewProvider {

    static let service = MockNoteService()

    static var previews: some View {
        InstaMainView(service: service)
    }
}
