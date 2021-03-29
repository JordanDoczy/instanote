//
//  CameraController.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/16/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Combine
import SwiftUI
import AVFoundation


// (Modified)
//
//  SwiftUI-CameraApp
//
//  Created by Gaspard Rosay on 28.01.20.
//  Copyright © 2020 Gaspard Rosay. All rights reserved.
//
class CameraController: NSObject, ObservableObject {
    let publisher = PassthroughSubject<UIImage, Never>()
    var saveCompletionHandler: ((UIImage?) -> Void)? = nil
    
    private var captureSession: AVCaptureSession?
    private var camera: AVCaptureDevice?
    private var cameraInput: AVCaptureDeviceInput?
    private var cameraOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void){
        func createCaptureSession(){
            captureSession = AVCaptureSession()
            captureSession!.sessionPreset = .hd1280x720
        }
        
        func configureCaptureDevices() throws {
            camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
            try camera?.lockForConfiguration() // leave camera optional for simulator testing
            camera?.unlockForConfiguration()
        }
        
        func configureDeviceInputs() throws  {
            guard let captureSession = captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let camera = camera {
                cameraInput = try AVCaptureDeviceInput(device: camera)
                
                if captureSession.canAddInput(cameraInput!) { captureSession.addInput(cameraInput!)}
                else { throw CameraControllerError.inputsAreInvalid }
                
            }
            else { throw CameraControllerError.noCamerasAvailable }
            
            captureSession.startRunning()
        }
        
        func configureDeviceOutputs() throws {
            guard let captureSession = captureSession else { throw CameraControllerError.captureSessionIsMissing }

            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput!) { captureSession.addOutput(cameraOutput!) }
            else { throw CameraControllerError.unknown }
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configureDeviceOutputs()
            }
                
            catch {
                DispatchQueue.main.async{
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    func displayPreview(on view: UIView) throws {
        guard let captureSession = captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        previewLayer!.connection?.videoOrientation = .portrait
        
        view.layer.addSublayer(previewLayer!)
        previewLayer!.frame = view.frame
    }
    
    func capturePhoto(completionHandler: ((UIImage?) -> Void)? = nil) {
        self.saveCompletionHandler = completionHandler
        cameraOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    func processPhoto(uiImage: UIImage) -> UIImage {
        guard var frame = previewLayer?.frame else { return uiImage }
        
        frame.size = CGSize(width: uiImage.size.width, height: uiImage.size.width)
        frame.origin = CGPoint(x: (uiImage.size.height/2)-(frame.width/2), y: (uiImage.size.width/2)-(frame.height/2))
        
        let croppedImage = uiImage.cropImage(toRect: frame)
        return croppedImage ?? uiImage
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let imageData = photo.fileDataRepresentation(), let rawUIImage = UIImage(data: imageData) else {
            saveCompletionHandler?(nil)
            return
        }
        
        let photo = processPhoto(uiImage: rawUIImage)
        
        publisher.send(photo)
        saveCompletionHandler?(photo)
    }
}
