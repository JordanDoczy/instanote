//
//  CameraView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/19/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import AVFoundation
import SwiftUI

struct CameraView: View {

    @StateObject var cameraController = CameraController()
    @Binding var outputImage: UIImage?

    var body: some View {
        ZStack {
            Color.darker
            VStack {
                preview
                    .aspectRatio(1.0, contentMode: .fill)
                Button {
                    cameraController.capturePhoto()
                } label: {
                    CameraViewShutterButton()
                }
                .disabled(cameraController.status != .running)
                Spacer()
            }
        }
        // Runs each time the Camera tab appears; stopping on disappear turns the camera off.
        .task {
            await cameraController.start()
        }
        .onDisappear {
            cameraController.stop()
        }
        .onReceive(cameraController.publisher) { outputImage in
            self.outputImage = outputImage
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch cameraController.status {
        case .denied:
            message("Camera access is turned off. You can turn it on in Settings.")
        case .unavailable:
            message("The camera isn't available on this device.")
        case .starting, .running:
            CameraViewPreview(session: cameraController.capture.session)
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    struct CameraViewShutterButton: View {

        var body: some View {
            ZStack {
                Circle()
                    .frame(width: 100)
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

    /// A UIView backed by a preview layer, so the preview always matches the view's bounds.
    final class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    struct CameraViewPreview: UIViewRepresentable {

        let session: AVCaptureSession

        func makeUIView(context: Context) -> PreviewUIView {
            let view = PreviewUIView()
            view.previewLayer.session = session
            view.previewLayer.videoGravity = .resizeAspectFill
            return view
        }

        func updateUIView(_ uiView: PreviewUIView, context: Context) { }
    }
}

#Preview {
    CameraView(outputImage: .constant(nil))
}
