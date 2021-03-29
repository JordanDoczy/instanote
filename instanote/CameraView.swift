//
//  CameraView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/19/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

struct CameraView: View {
    
    @StateObject var cameraController = CameraController()
    @Binding var outputImage: UIImage?

    var body: some View {
        ZStack {
            Color.darker
            VStack {
                CameraViewPreview(cameraController: cameraController)
                    .aspectRatio(1.0, contentMode: .fill)
                Button {
                    cameraController.capturePhoto()
                } label: {
                    CameraViewShutterButton()
                }
                Spacer()
            }
        }
        .onReceive(cameraController.publisher) { outputImage in
            self.outputImage = outputImage
        }
    }
    
    struct CameraViewShutterButton: View {

        var body: some View {
            ZStack {
                Circle()
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.white)
                Circle()
                    .frame(width: 95)
                    .foregroundColor(.black)
                Circle()
                    .frame(width: 88)
                    .foregroundColor(.primaryColor)
            }
        }
    }

    struct CameraViewPreview: UIViewRepresentable {
        
        @ObservedObject var cameraController: CameraController
        
        func makeUIView(context: Context) -> some UIView {
            let previewView = UIView()

            cameraController.prepare { error in
                guard error == nil else { return }
                try? cameraController.displayPreview(on: previewView)
            }

            return previewView
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) { }
    }
}

struct CameraView_Previews: PreviewProvider {
    
    static var previews: some View {
        CameraView(outputImage: .constant(nil))
    }
}
