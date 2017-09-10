//
//  CameraViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/3/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class CameraViewController: UIViewController {
    
    fileprivate struct Constants {
        struct Selectors {
            static let Focus:Selector = #selector(CameraViewController.focus(_:))
            static let ShutterPressed:Selector = #selector(CameraViewController.shutterPressed(_:))
        }
        struct Segues {
            static let CreateNote = "Create Note"
            static let UnwindToCreateNote = "Unwind To Create Note"
            static let UnwindToHome = "Unwind To Home"
        }
    }
    
    // MARK: Private Members
    fileprivate lazy var captureDevice : AVCaptureDevice? = {
        let lazy = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        return lazy
    }()
    fileprivate lazy var captureSession:AVCaptureSession = {
        let lazy = AVCaptureSession()
        lazy.sessionPreset = AVCaptureSessionPreset640x480
        return lazy
    }()
    fileprivate var capturedImage:UIImage?
    fileprivate var firstLoad:Bool = true
    fileprivate var focusIndicator:UIImageView = {
        let lazy = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 40, height: 40)))
        lazy.image = UIImage(named: Assets.Focus)
        lazy.isHidden = true
        lazy.alpha = 0.9
        return lazy
    }()
    fileprivate var input:AVCaptureDeviceInput?
    fileprivate var isUnwind:Bool{
        return !(presentingViewController is MainTabBarController)
    }
    fileprivate lazy var output:AVCaptureStillImageOutput = {
        let lazy = AVCaptureStillImageOutput()
        lazy.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        return lazy
    }()
    fileprivate lazy var overlay:UIView = { [unowned self] in
        let lazy = UIView(frame: self.view.bounds)
        lazy.backgroundColor = Colors.Transparent
        lazy.isHidden = true
        self.view.addSubview(lazy)
        return lazy
    }()
    fileprivate var previewLayer:AVCaptureVideoPreviewLayer?
    fileprivate lazy var previewView:UIView = {
        let lazy = UIView()
        lazy.alpha = 0
        return lazy
    }()
    fileprivate var spacer:CGFloat = 0
    fileprivate var shutterButton = ShutterButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 80)))
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if input != nil{
            startCamera()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if input != nil{
            stopCamera()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: IBActions
    @IBAction func close(_ sender: UIBarButtonItem) {
        if isUnwind {
            performSegue(withIdentifier: Constants.Segues.UnwindToCreateNote, sender: self)
        } else {
            performSegue(withIdentifier: Constants.Segues.UnwindToHome, sender: self)
        }
    }
    
    
    // MARK: Overrides
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if capturedImage != nil {
            if segue.identifier == Constants.Segues.CreateNote || segue.identifier == Constants.Segues.UnwindToCreateNote{
                var destination = segue.destination
                if let navController = destination as? UINavigationController {
                    destination = navController.visibleViewController!
                }
                if let controller = destination as? CreateNoteViewController{
                    controller.image = capturedImage
                }
            }
        }
    }
    
    // MARK: Camera Methods
    fileprivate func setUpCamera(){
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            captureSession.addOutput(output)

            previewView.frame = CGRect(origin: CGPoint(x:spacer, y:spacer), size: CGSize(width: view.frame.width - (spacer * 2), height: view.frame.width - (spacer * 2)))
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.frame = CGRect(origin: CGPoint.zero, size: previewView.frame.size)
            previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewView.layer.addSublayer(previewLayer!)
            previewView.addSubview(focusIndicator)
            previewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Constants.Selectors.Focus))
            
            let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
            let navigationHeight = navigationController?.navigationBar.frame.height ?? 0
            
            shutterButton.frame.origin = CGPoint(x: view.center.x - shutterButton.frame.width/2, y: previewView.frame.origin.y + previewView.frame.height + (view.frame.height - tabBarHeight - navigationHeight - previewView.frame.height)/2 - shutterButton.frame.height/2 )
            shutterButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Constants.Selectors.ShutterPressed))

            view.addSubview(shutterButton)
            view.addSubview(previewView)
            
        }
        catch {}
    }

    func startCamera(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [unowned self] () -> Void in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: { [unowned self] in
                    self.previewView.alpha = 1
                })
            }
        }
    }
    
    func stopCamera(){
        overlay.isHidden = true
        shutterButton.reset()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [unowned self] () -> Void in
            self.captureSession.stopRunning()
        }
    }
    
    func focus(_ sender:UITapGestureRecognizer){
        func updateFocusPoint(_ point:CGPoint){
            focusIndicator.center = point
            focusIndicator.isHidden = false
            previewView.bringSubview(toFront: focusIndicator)
            UIView.animate(withDuration: 0.33, delay: 0, options: [.repeat, .autoreverse, .curveEaseOut],
                animations: { [unowned self] in
                    self.focusIndicator.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                },
                completion: nil
            )
        }

        let focusPoint = CGPoint(x: sender.location(in: previewView).y / previewView.bounds.size.height, y: 1.0 - sender.location(in: previewView).x / previewView.bounds.size.width)
        
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = focusPoint
                device.focusMode = AVCaptureFocusMode.continuousAutoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
                updateFocusPoint(sender.location(in: previewView))
            } catch {}
        }
    }
    
    func shutterPressed(_ sender:UITapGestureRecognizer){
        shutterButton.depress()
        
        if let videoConnection = output.connection(withMediaType: AVMediaTypeVideo) {
            output.captureStillImageAsynchronously(from: videoConnection, completionHandler: { [unowned self] (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProvider(data: imageData as! CFData)
                if let cgImage = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                    self.capturedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
                    if self.isUnwind {
                        self.performSegue(withIdentifier: Constants.Segues.UnwindToCreateNote, sender: self)
                    } else {
                        self.performSegue(withIdentifier: Constants.Segues.CreateNote, sender: self)
                    }
                }
            })
        }
    }
}

class ShutterButton : UIButton{
    
    fileprivate var innerCircle = InnerCircle(color: Colors.Primary)
    fileprivate var innerCircleHighlight = InnerCircle(color: UIColor.white)
    
    fileprivate struct Constants{
        struct Selectors{
            static let Tapped:Selector = "tapped:"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize(){
        innerCircle.backgroundColor = UIColor.clear
        innerCircle.frame = frame
        
        innerCircleHighlight.backgroundColor = UIColor.clear
        innerCircleHighlight.frame = frame
        innerCircleHighlight.alpha = 0
        
        addSubview(innerCircle)
        addSubview(innerCircleHighlight)
    }
    
    func reset(){
        self.innerCircleHighlight.alpha = 0
    }
    
    func press(){
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut],
            animations: { [unowned self] in
                self.innerCircleHighlight.alpha = 0.5
            }, completion: nil)
        
    }
    
    func depress(){
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut],
            animations: { [unowned self] in
                self.innerCircleHighlight.alpha = 0
            }, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        press()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        depress()
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        createConcentricCircle(rect, percentage: 1).fill()
        
        UIColor.black.setFill()
        createConcentricCircle(rect, percentage: 0.95).fill()
    }
    
    class InnerCircle : UIView{
        var color:UIColor = UIColor.clear
        
        convenience init(color:UIColor){
            self.init()
            self.color = color
        }
        
        override func draw(_ rect: CGRect) {
            color.setFill()
            createConcentricCircle(rect, percentage: 0.85).fill()
        }
    }
}

extension UIView{
    func createConcentricCircle(_ rect:CGRect, percentage:CGFloat)->UIBezierPath {
        let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: rect.midX - rect.width * percentage/2, y: rect.midY - rect.height * percentage/2), size: CGSize(width: rect.width * percentage, height: rect.height * percentage)))
        return path
    }
}
