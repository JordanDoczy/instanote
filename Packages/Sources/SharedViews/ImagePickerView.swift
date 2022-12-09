import Foundation
import PhotosUI
import SwiftUI

public struct ImagePickerView: UIViewControllerRepresentable {

    public final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: ImagePickerView

        public init(picker: ImagePickerView) {
            self.picker = picker
        }

        public func imagePickerControllerDidUpdate(_ controller: UIImagePickerController) { }

        public func imagePickerControllerDidCancel(_ controller: UIImagePickerController) {
            picker.didCancel()
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else {
                return
            }
            self.picker.selectedImage(selectedImage)
        }
    }

    public var sourceType: UIImagePickerController.SourceType
    public var didCancel: () -> Void
    public var selectedImage: (UIImage?) -> Void

    public init(
        sourceType: UIImagePickerController.SourceType,
        didCancel: @escaping () -> Void,
        selectedImage: @escaping (UIImage?) -> Void
    ) {
        self.sourceType = sourceType
        self.didCancel = didCancel
        self.selectedImage = selectedImage
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(picker: self)
    }
}

