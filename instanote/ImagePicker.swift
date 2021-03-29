//
//  ImageLibraryView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/13/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let resizedImage = uiImage.resizeImage(targetSize: picker.view.frame.size)

                let shortestSide = min(resizedImage.size.width, resizedImage.size.height)
                let longestSide = max(resizedImage.size.width, resizedImage.size.height)

                var frame = CGRect()
                frame.size = CGSize(width: shortestSide, height: shortestSide)
                frame.origin = CGPoint(x: 0, y: longestSide/2 - shortestSide/2)

                let cgImage: CGImage = resizedImage.cgImage!.cropping(to: frame)!
                let croppedImage = UIImage(cgImage: cgImage)

                parent.outputImage = croppedImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var outputImage: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.view.backgroundColor = .black
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}


struct ImagePicker_Previews: PreviewProvider {
    
    static var previews: some View {
        ImagePicker(outputImage: .constant(nil))
    }
}
