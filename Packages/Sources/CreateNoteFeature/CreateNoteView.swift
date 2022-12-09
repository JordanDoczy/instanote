import ComposableArchitecture
import Foundation
import SharedViews
import SwiftUI

public struct CreateNoteFeature: ReducerProtocol {

    public struct State: Equatable {

        public enum ImagePickerState {
            case camera
            case library
        }

        public var selectedImage: UIImage?
        public var imagePickerState: ImagePickerState?

        public init(selectedImage: UIImage? = nil, imagePickerState: ImagePickerState? = .camera) {
            self.selectedImage = selectedImage
            self.imagePickerState = imagePickerState
        }
    }

    public enum Action {
        case onAppear
        case imageSelected(UIImage?)
    }

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .imageSelected(image):
                state.selectedImage = image
                state.imagePickerState = nil
                return .none
            }
        }
    }

}

public struct CreateNoteView: View {

    let store: StoreOf<CreateNoteFeature>
    @ObservedObject var viewStore: ViewStoreOf<CreateNoteFeature>

    public init(store: StoreOf<CreateNoteFeature>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        imagePicker
    }

    @ViewBuilder
    var imagePicker: some View {
        switch viewStore.imagePickerState {
        case .camera, .library:
            ImagePickerSelectorView(
                didCancel: {
                    viewStore.send(.imageSelected(nil))
                },
                selectedImage: {
                    viewStore.send(.imageSelected($0))
                }
            )
        case .none:
            EmptyView()
        }
    }

}

struct ImagePickerSelectorView: View {
    @State var pickerSource: UIImagePickerController.SourceType = .camera

    var didCancel: () -> ()
    var selectedImage: (UIImage?) -> ()

    public var body: some View {
        VStack {
            switch pickerSource {
            case .camera:
                ImagePickerView(
                    sourceType: .camera,
                    didCancel: didCancel,
                    selectedImage: selectedImage
                )
            case .photoLibrary:
                ImagePickerView(
                    sourceType: .photoLibrary,
                    didCancel: didCancel,
                    selectedImage: selectedImage
                )
            case .savedPhotosAlbum:
                EmptyView()
            @unknown default:
                EmptyView()
            }

            Picker("", selection: $pickerSource) {
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tag(UIImagePickerController.SourceType.camera)
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .tag(UIImagePickerController.SourceType.photoLibrary)
            }
            .pickerStyle(.segmented)
        }

    }
}
