//
//  EditNoteView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/12/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI
import MapKit
import CoreData
import Combine

struct EditNoteView: View {
    @ObservedObject var viewModel: EditNoteViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteActionSheet = false
    @State private var state: EditNoteViewState = .picture
    
    private func updateState() {
        state = viewModel.hasImage ? .picture : .camera
    }
    
    private func endEditingCaption() {
        hideKeyboard()
        viewModel.caption = viewModel.caption.isEmpty ? Constants.defaultText : viewModel.caption
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { frame in
                ZStack(alignment: .topLeading) {
                    Color.primaryColor
                        .ignoresSafeArea()
                    switch (state) {
                    case .picture:
                        if let image = viewModel.uiImage { // image came from camera or image picker
                            Image(uiImage: image)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: frame.size.width)
                                .onTapGesture {
                                    endEditingCaption()
                                }
                        } else if let imagePath = viewModel.imagePath  { // image came from storage
                            ImageView(with: imagePath)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: frame.size.width)
                                .onTapGesture {
                                    endEditingCaption()
                                }
                        }
                        VStack (alignment: .leading) {
                            if !viewModel.tags.isEmpty { // auto tag search
                                VStack (alignment: .leading, spacing: 0) {
                                    ForEach (viewModel.tags, id: \.self) { tag in
                                        Button {
                                            viewModel.updateTag(tag: tag)
                                        } label: {
                                            Text(tag)
                                                .foregroundColor(.dark)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                                .background(Color.white)
                                        }
                                        Divider()
                                    }
                                }
                                
                            }
                            TextEditor(text: $viewModel.caption) // note caption & tags
                                .font(.body)
                                .frame(maxWidth: .infinity, maxHeight: 200.0)
                                .padding(15)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .onTapGesture {
                                    if viewModel.caption == Constants.defaultText {
                                        viewModel.caption = ""
                                    }
                                }
                            
                        }
                        .background(LinearGradient(gradient: Gradient(colors: [.darker, Color.primaryColor.opacity(0)]),
                                                   startPoint: .top,
                                                   endPoint: .bottom))
                    case .map:
                        if let location = viewModel.location {
                            MapView(location: location, title: viewModel.caption)
                        }
                    case .camera:
                        ChoosePhotoView(outputImage: $viewModel.uiImage)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        EditNoteNavItem(myState: .picture, state: $state)
                        EditNoteNavItem(myState: .map, state: $state)
                        EditNoteNavItem(myState: .camera, state: $state)
                        Button {
                            showingDeleteActionSheet = true
                        } label: {
                            Image(systemName: "trash.fill")
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                                .background(Color.primaryColor.opacity(0.75))
                        }
                    }
                    .opacity(viewModel.hasImage ? 1 : 0)
                    .position(x: 25, y: frame.size.height/1.5)
                    
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .modifier(EditNoteNavigationModifier(title: viewModel.title,
                                                 cancelAction: {
                                                    viewModel.cancel()
                                                    presentationMode.wrappedValue.dismiss()
                                                 },
                                                 saveAction: {
                                                    viewModel.save()
                                                    presentationMode.wrappedValue.dismiss()
                                                 }))
            .modifier(EditNoteDeleteActionSheetModifier(isPresented: $showingDeleteActionSheet) {
                viewModel.delete()
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear() {
                updateState()
            }
            .onChange(of: viewModel.uiImage) { _ in
                updateState()
            }
        }
    }
}

extension EditNoteView {
    
    struct Constants {
        static var defaultText = "Enter your caption here."
        static var maxCaptionCharacterCount = 123
        static var maxTagMatches = 3
    }
    
    class EditNoteViewModel: ObservableObject {

        @ObservedObject var locationManager = LocationManager()
        
        @Published var caption: String {
            didSet {
                tagRange = nil
                if caption.count > Constants.maxCaptionCharacterCount {
                    caption = oldValue
                } else {
                    tagRange = updateTags(oldValue: oldValue, newValue: caption)
                }
            }
        }
        @Published var imagePath: String? = nil
        @Published var location: CLLocationCoordinate2D? = nil
        @Published var tags: [String] = []
        @Published var uiImage: UIImage? = nil


        var hasImage: Bool { imagePath != nil || uiImage != nil }
        var title: String { note == nil ? "Create Note" : "Edit Note" }
        
        private var cancellable: AnyCancellable? = nil
        private var note: Note?
        private var service: NoteService
        private var tagRange: Range<String.Index>? = nil
        
        init(service: NoteService, caption: String? = nil, imagePath: String? = nil, uiImage: UIImage? = nil, location: CLLocationCoordinate2D? = nil) {
            self.service = service
            self.caption = caption ?? Constants.defaultText
            self.imagePath = imagePath
            self.uiImage = uiImage
            self.location = location

            if location == nil {
                locationManager.requestAccess() // request access and start polling for location
                cancellable = locationManager.$location.sink { [weak self] location in
                    self?.location = location?.coordinate
                    self?.locationManager.stop() // only get location once
                    self?.cancellable?.cancel()
                }
            }
            
        }
        
        convenience init(service: NoteService, note: Note?) {
            self.init(service: service, caption: note?.caption ?? nil, imagePath: note?.imagePath ?? nil, location: note?.coordinate ?? nil)
            self.note = note
        }
        
        func cancel() {
            service.rollback()
        }
        
        func delete() {
            guard let note = note else { return }
            service.deleteNote(note)
            service.save()
        }
        
        func save() {
            let note = self.note ?? service.createNote()

            service.updateNote(note, caption: caption, uiImage: uiImage, location: location)
            service.save()
        }
        
        func updateTag(tag: String) {
            guard let tagRange = tagRange else { return }
            caption.replaceSubrange(tagRange, with: tag)
        }

        private func getRangeOfCurrentEdit(oldValue: String, newValue: String) -> Range<String.Index>? {
            guard oldValue != newValue else { return nil }
            
            // find common prefix between the strings
            let prefix = oldValue.commonPrefix(with: newValue)
            
            // find where the strings differ
            if let range = newValue.range(of: prefix),

               // find the nearest #
               let hash = newValue.range(of: "#", options: .backwards, range: newValue.startIndex..<range.upperBound) {
                
                // find the nearest ' '
                let leadingSpace = newValue.range(of: " ", options: .backwards, range: hash.upperBound..<range.upperBound )
                
                // if the ' ' is before the #, the user is not editing a tag
                if let leadingSpace = leadingSpace, leadingSpace.upperBound > hash.upperBound {
                    return nil
                }
                
                // find the trailing space or use the endIndex
                let trailingSpaceIndex = newValue.range(of: " ", range: hash.upperBound..<newValue.endIndex)?.lowerBound ?? newValue.endIndex
                
                return hash.upperBound..<trailingSpaceIndex
            }
            
            return nil
        }
        
        private func updateTags(oldValue: String, newValue: String) -> Range<String.Index>? {
            if let range = getRangeOfCurrentEdit(oldValue: oldValue, newValue: newValue) {
                let tag = newValue[range].trimmingCharacters(in: .whitespaces)
                var tags = service.getTags(tag) ?? []

                if tags.count > EditNoteView.Constants.maxTagMatches {
                    tags = Array(tags[0..<EditNoteView.Constants.maxTagMatches])
                }
                
                self.tags = tags.map { $0.name ?? "" }
                return range
            }
            
            self.tags = []
            return nil
        }
    }
    
    enum EditNoteViewState: String {
        case picture = "photo.fill"
        case camera = "camera.fill"
        case map = "mappin.and.ellipse"
    }
    
    struct EditNoteNavItem: View {
        
        var myState: EditNoteViewState
        
        @Binding var state: EditNoteViewState
        
        var body: some View {
            Button {
                state = myState
            } label: {
                Image(systemName: myState.rawValue)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .background(state == myState ? Color.lightGray.opacity(0.75) : Color.primaryColor.opacity(0.75))
            }
            .disabled(state == myState)
        }
    }
    
    struct EditNoteNavigationModifier: ViewModifier {
        
        var title = "Edit Note"
        var cancelAction: () -> Void
        var saveAction: () -> Void
        
        func body(content: Content) -> some View {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(title)
                                .font(Font.headline)
                                .foregroundColor(.white)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            cancelAction()
                        } label: {
                            Text("Cancel")
                                .font(Font.body)
                                .foregroundColor(.white)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            saveAction()
                        } label: {
                            Text("Done")
                                .font(Font.body)
                                .foregroundColor(.white)
                        }
                    }
                }
                .modifier(NavigationBarModifier(backgroundColor: Color.primaryColor.toUIColor(), textColor: .white))
        }
    }
    
    struct EditNoteDeleteActionSheetModifier: ViewModifier {
        
        @Binding var isPresented: Bool
        var deleteAction: () -> Void
        
        func body(content: Content) -> some View {
            content
                .actionSheet(isPresented: $isPresented) {
                    ActionSheet(title: Text(""),
                                message: Text("Are you sure you want to delete?"),
                                buttons: [
                                    .destructive(Text("Delete")) {
                                        deleteAction()
                                    },
                                    .cancel()
                                ])
                }
        }
    }
}

struct EditNoteView_Previews: PreviewProvider {
    
    static let service = MockNoteService()
    
    static var previews: some View {
        EditNoteView(viewModel: EditNoteView.EditNoteViewModel(service: service,
                                                               note: service.notes.first!))
        EditNoteView(viewModel: EditNoteView.EditNoteViewModel(service: service))
    }
}
