//
//  CameraController.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/16/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import AVFoundation
import Combine
import UIKit

/// Owns the AVCaptureSession. AVFoundation requires session configuration and
/// `startRunning()` (which blocks) to happen off the main thread, so every member is only
/// touched on `queue`. That confinement is what makes `@unchecked Sendable` safe here.
nonisolated final class CaptureSession: @unchecked Sendable {

    enum CaptureError: Error {
        case noCameraAvailable
        case invalidConfiguration
    }

    /// Exposed only so the preview layer can attach to it, which Apple allows from the main thread.
    let session = AVCaptureSession()

    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "com.jordandoczy.InstaNote.camera-session")
    private var isConfigured = false

    /// The app is portrait-only, so photos are always captured upright for portrait.
    private static let portraitRotationAngle: CGFloat = 90

    func start() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async {
                do {
                    try self.configureIfNeeded()
                    if !self.session.isRunning {
                        self.session.startRunning()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func stop() {
        queue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func capturePhoto(delegate: any AVCapturePhotoCaptureDelegate & Sendable) {
        queue.async {
            guard self.isConfigured, self.session.isRunning else { return }

            if let connection = self.output.connection(with: .video),
               connection.isVideoRotationAngleSupported(Self.portraitRotationAngle) {
                connection.videoRotationAngle = Self.portraitRotationAngle
            }

            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: delegate)
        }
    }

    private func configureIfNeeded() throws {
        guard !isConfigured else { return }

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CaptureError.noCameraAvailable
        }
        let input = try AVCaptureDeviceInput(device: camera)

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo
        guard session.canAddInput(input), session.canAddOutput(output) else {
            throw CaptureError.invalidConfiguration
        }
        session.addInput(input)
        session.addOutput(output)
        isConfigured = true
    }
}

final class CameraController: NSObject, ObservableObject {

    enum Status: Equatable {
        case starting
        case running
        case denied
        case unavailable
    }

    let publisher = PassthroughSubject<UIImage, Never>()
    let capture = CaptureSession()

    @Published private(set) var status = Status.starting

    func start() async {
        // Returns immediately when the user has already answered the permission prompt.
        guard await AVCaptureDevice.requestAccess(for: .video) else {
            status = .denied
            return
        }

        do {
            try await capture.start()
            status = .running
        } catch {
            status = .unavailable
        }
    }

    func stop() {
        capture.stop()
        if status == .running {
            status = .starting
        }
    }

    func capturePhoto() {
        capture.capturePhoto(delegate: self)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {

    // AVFoundation calls this on its own queue. Decoding and cropping a full-size photo is
    // slow, so it happens here, and only the finished image is sent to the main actor.
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)?.squareCropped(maxPixelSide: UIImage.notePhotoMaxPixelSide)
        else { return }

        Task { @MainActor in
            self.publisher.send(image)
        }
    }
}
