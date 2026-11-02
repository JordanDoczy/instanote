//
//  PhotoLibraryView.swift
//  InstaNote
//
//  Copyright © 2026 Jordan Doczy. All rights reserved.
//

import PhotosUI
import SwiftUI

/// The Library tab: an inline photo picker. It runs outside the app, so no photo library permission is needed.
struct PhotoLibraryView: View {

    @Binding var outputImage: UIImage?

    @State private var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images, preferredItemEncoding: .current) {
            Text("Choose a photo")
        }
        .photosPickerStyle(.inline)
        .photosPickerDisabledCapabilities(.selectionActions)
        .ignoresSafeArea(edges: .bottom)
        .task(id: selection) {
            guard let selection,
                  let data = try? await selection.loadTransferable(type: Data.self)
            else { return }

            // Decoding and cropping a full-size photo is slow, so keep it off the main actor.
            let photo = await Task.detached(priority: .userInitiated) {
                UIImage(data: data)?.squareCropped(maxPixelSide: UIImage.notePhotoMaxPixelSide)
            }.value

            if let photo {
                outputImage = photo
            }
        }
    }
}

#Preview {
    PhotoLibraryView(outputImage: .constant(nil))
}
