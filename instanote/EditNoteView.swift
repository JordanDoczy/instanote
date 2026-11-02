//
//  EditNoteView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/12/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import CoreLocation
import Observation
import SwiftUI

struct EditNoteView: View {
    @Bindable var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            GeometryReader { frame in
                ZStack(alignment: .topLeading) {
                    Color.darker.ignoresSafeArea()
                    content(size: frame.size)
                    navigation(size: frame.size)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .modifier(EditNoteNavigationModifier(title: viewModel.title,
                 cancelAction: {
                    viewModel.cancel()
                    dismiss()
                 },
                 saveAction: {
                    viewModel.save()
                    dismiss()
                 }))
            .modifier(EditNoteDeleteActionSheetModifier(isPresented: $viewModel.showingDeleteActionSheet) {
                viewModel.delete()
                dismiss()
            })
        }
        .tint(Color.primaryColor)
    }
    
    @ViewBuilder
    func content(size: CGSize) -> some View {
        switch viewModel.state {
        case let .picture(.some(image)):
            photoView(image: image, size: size)
        case let .map(.some(location)):
            MapView(location: location, title: viewModel.caption)
        case .camera:
            ChoosePhotoView(outputImage: $viewModel.uiImage)
        default:
            EmptyView()
        }
    }
    
    func navigation(size: CGSize) -> some View {
        // One container lets the glass buttons blend together as a single rail.
        GlassEffectContainer(spacing: 8) {
            VStack(spacing: 8) {
                EditNoteNavItem(myState: .picture(image: viewModel.uiImage), state: $viewModel.state)
                EditNoteNavItem(myState: .map(location: viewModel.location), state: $viewModel.state)
                EditNoteNavItem(myState: .camera, state: $viewModel.state)
                Button {
                    viewModel.showingDeleteActionSheet = true
                } label: {
                    Image(systemName: "trash.fill")
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.white)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .accessibilityLabel("Delete")
            }
        }
        .opacity(viewModel.hasImage ? 1 : 0)
        .position(x: 37, y: size.height/1.5)
    }

    func photoView(image: UIImage, size: CGSize) -> some View {
        return
            Group {
                Image(uiImage: image) // note image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width)
                    .onTapGesture {
                        hideKeyboard()
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
                        .keyboardType(.twitter)
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: 200.0)
                        .padding(15)
                        .foregroundStyle(.white)
                        .tint(.white)
                        .scrollContentBackground(.hidden)
                        .onTapGesture {
                            if viewModel.caption == Constants.defaultText {
                                viewModel.caption = ""
                            }
                        }
                }
                .background(LinearGradient(gradient: Gradient(colors: [.darker, Color.primaryColor.opacity(0)]),
                                           startPoint: .top,
                                           endPoint: .bottom))
            }
    }
}

extension EditNoteView {
    
    struct Constants {
        static let defaultText = "Enter your caption here."
        static let maxCaptionCharacterCount = 123
        static let maxTagMatches = 3
    }
    
    @Observable
    final class ViewModel: Identifiable {

        /// Edits longer than `maxCaptionCharacterCount` are rejected.
        var caption: String {
            get { storedCaption }
            set {
                guard newValue.count <= Constants.maxCaptionCharacterCount else {
                    storedCaption = storedCaption // still notify, so the text field reverts
                    return
                }
                let oldValue = storedCaption
                storedCaption = newValue
                tagRange = updateTags(oldValue: oldValue, newValue: newValue)
            }
        }
        var location: CLLocationCoordinate2D? = nil
        var showingDeleteActionSheet = false
        var state = EditNoteViewState.camera
        var tags: [String] = []
        var uiImage: UIImage? = nil {
            didSet {
                if uiImage != nil {
                    state = .picture(image: uiImage!)
                }
            }
        }
        
        var hasImage: Bool { uiImage != nil }
        var title: String { note == nil ? "Create Note" : "Edit Note" }
        
        private var storedCaption: String
        @ObservationIgnored private var locationTask: Task<Void, Never>? = nil
        @ObservationIgnored private var note: Note?
        /// The photo the note already had, so saving can tell whether the user picked a new one.
        @ObservationIgnored private var originalImage: UIImage? = nil
        @ObservationIgnored private let service: NoteService
        @ObservationIgnored private var tagRange: Range<String.Index>? = nil
        
        /// `currentLocation` is used for notes without a location; tests pass a stub so they don't touch CoreLocation.
        init(service: NoteService,
             caption: String? = nil,
             imagePath: String? = nil,
             location: CLLocationCoordinate2D? = nil,
             currentLocation: @escaping () async -> CLLocationCoordinate2D? = CurrentLocation.coordinate) {
            self.service = service
            self.storedCaption = caption ?? Constants.defaultText
            self.location = location

            if let imagePath = imagePath {
                if let image = ImageLoader.localImage(urlString: imagePath) {
                    originalImage = image
                    uiImage = image
                } else {
                    loadRemoteImage(urlString: imagePath)
                }
            }

            // didSet doesn't run during init, so set the starting screen directly.
            state = uiImage.map { .picture(image: $0) } ?? .camera

            if location == nil {
                locationTask = Task { [weak self] in
                    let coordinate = await currentLocation()
                    guard let self, self.location == nil else { return }
                    self.location = coordinate
                }
            }
        }

        isolated deinit {
            locationTask?.cancel()
        }
        
        convenience init(service: NoteService,
                         note: Note?,
                         currentLocation: @escaping () async -> CLLocationCoordinate2D? = CurrentLocation.coordinate) {
            self.init(service: service,
                      caption: note?.caption ?? nil,
                      imagePath: note?.imagePath ?? nil,
                      location: note?.location?.coordinate,
                      currentLocation: currentLocation)
            
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
            let savedCaption = caption == Constants.defaultText ? "" : caption
            // Only pass a photo when it changed; passing one replaces the file on disk.
            let newImage = uiImage === originalImage ? nil : uiImage

            service.updateNote(note, caption: savedCaption, uiImage: newImage, location: location)
            service.save()
        }

        private func loadRemoteImage(urlString: String) {
            Task { [weak self] in
                guard let image = await ImageLoader.fetchImage(urlString: urlString),
                      let self,
                      uiImage == nil // the user may have picked a photo while this loaded
                else { return }

                originalImage = image
                uiImage = image
            }
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
    
    enum EditNoteViewState: Equatable {
        case picture(image: UIImage?)
        case camera
        case map(location: CLLocationCoordinate2D?)
        
        var icon: String {
            switch self {
            case .picture(_): return "photo.fill"
            case .camera: return "camera.fill"
            case .map: return "mappin.and.ellipse"
            }
        }

        /// Spoken by VoiceOver for the side buttons.
        var title: String {
            switch self {
            case .picture: return "Photo"
            case .camera: return "Change Photo"
            case .map: return "Map"
            }
        }
    }
    
    struct EditNoteNavItem: View {
        
        var myState: EditNoteViewState
        
        @Binding var state: EditNoteViewState
        
        var body: some View {
            let isSelected = state == myState
            Button {
                state = myState
            } label: {
                Image(systemName: myState.icon)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            // The current screen's button is tinted; the others are clear glass.
            .glassEffect(isSelected ? .regular.tint(.primaryColor).interactive() : .regular.interactive(), in: .circle)
            .disabled(isSelected)
            .accessibilityLabel(myState.title)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }
    
    struct EditNoteNavigationModifier: ViewModifier {
        
        var title = "Edit Note"
        var cancelAction: () -> Void
        var saveAction: () -> Void
        
        func body(content: Content) -> some View {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // iOS 26 shows these as glass close (✕) and prominent confirm (✓) buttons.
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel, action: cancelAction)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(role: .confirm, action: saveAction)
                    }
                }
        }
    }
    
    struct EditNoteDeleteActionSheetModifier: ViewModifier {
        
        @Binding var isPresented: Bool
        var deleteAction: () -> Void
        
        func body(content: Content) -> some View {
            content
                .confirmationDialog("Delete Note", isPresented: $isPresented, titleVisibility: .hidden) {
                    Button("Delete", role: .destructive) {
                        deleteAction()
                    }
                } message: {
                    Text("Are you sure you want to delete?")
                }
        }
    }
}

#Preview("New Note") {
    EditNoteView(viewModel: .init(service: MockNoteService(), currentLocation: { nil }))
        .preferredColorScheme(.dark)
}

#Preview("With Photo") {
    let viewModel = EditNoteView.ViewModel(service: MockNoteService(),
                                           caption: "Sunny day at the beach #beach",
                                           location: CLLocationCoordinate2D(latitude: 20.7984, longitude: -156.3319))
    viewModel.uiImage = UIImage(named: "hula")
    return EditNoteView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
