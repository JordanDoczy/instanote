//
//  CreateNoteView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/12/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI

struct ChoosePhotoView: View {
    
    @Binding var outputImage: UIImage?

    var body: some View {
        TabView {
            CameraView(outputImage: $outputImage)
            .tabItem { Label("Camera", systemImage: "camera.fill")  }
            ImagePicker(outputImage: $outputImage)
            .tabItem { Label("Library", systemImage: "photo.on.rectangle.angled") }
        }
        .accentColor(Color.primaryColor)
    }
}


struct ChoosePhotoView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChoosePhotoView(outputImage: .constant(nil))
    }
}
