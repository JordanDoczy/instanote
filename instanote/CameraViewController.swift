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
    
    private struct Constants {
        struct Selectors {
            static let Focus:Selector = "focus:"
            static let ShutterPressed:Selector = "shutterPressed:"
        }
        struct Segues {
            static let CreateNote = "Create Note"
            static let UnwindToCreateNote = "Unwind To Create Note"
            static let UnwindToHome = "Unwind To Home"
        }
    }
    
    // MARK: Private Members
    private lazy var captureDevice : AVCaptureDevice? = {
        let lazy = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        return lazy
    }()
    private lazy var captureSession:AVCaptureSession = {
        let lazy = AVCaptureSession()
        lazy.sessionPreset = AVCaptureSessionPreset640x480
        return lazy
    }()
    private var capturedImage:UIImage?
    private var firstLoad:Bool = true
    private var focusIndicator:UIImageView = {
        let lazy = UIImageView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 40, height: 40)))
        lazy.image = UIImage(named: Assets.Focus)
        lazy.hidden = true
        lazy.alpha = 0.9
        return lazy
    }()
    private var input:AVCaptureDeviceInput?
    private var isUnwind:Bool{
        return !(presentingViewController is MainTabBarController)
    }
    private lazy var output:AVCaptureStillImageOutput = {
        let lazy = AVCaptureStillImageOutput()
        lazy.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        return lazy
    }()
    private lazy var overlay:UIView = { [unowned self] in
        let lazy = UIView(frame: self.view.bounds)
        lazy.backgroundColor = Colors.Transparent
        lazy.hidden = true
        self.view.addSubview(lazy)
        return lazy
    }()
    private var previewLayer:AVCaptureVideoPreviewLayer?
    private lazy var previewView:UIView = {
        let lazy = UIView()
        lazy.alpha = 0
        return lazy
    }()
    private var spacer:CGFloat = 0
    private var shutterButton = ShutterButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if input != nil{
            startCamera()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if input != nil{
            stopCamera()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: IBActions
    @IBAction func close(sender: UIBarButtonItem) {
        if isUnwind {
            performSegueWithIdentifier(Constants.Segues.UnwindToCreateNote, sender: self)
        } else {
            performSegueWithIdentifier(Constants.Segues.UnwindToHome, sender: self)
        }
    }
    
    
    // MARK: Overrides
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if capturedImage != nil {
            if segue.identifier == Constants.Segues.CreateNote || segue.identifier == Constants.Segues.UnwindToCreateNote{
                var destination = segue.destinationViewController
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
    private func setUpCamera(){
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            captureSession.addOutput(output)

            previewView.frame = CGRect(origin: CGPoint(x:spacer, y:spacer), size: CGSize(width: view.frame.width - (spacer * 2), height: view.frame.width - (spacer * 2)))
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer!.frame = CGRect(origin: CGPointZero, size: previewView.frame.size)
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
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [unowned self] () -> Void in
            self.captureSession.startRunning()
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.25){ [unowned self] in
                    self.previewView.alpha = 1
                }
            }
        }
    }
    
    func stopCamera(){
        overlay.hidden = true
        shutterButton.reset()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { [unowned self] () -> Void in
            self.captureSession.stopRunning()
        }
    }
    
    func focus(sender:UITapGestureRecognizer){
        func updateFocusPoint(point:CGPoint){
            focusIndicator.center = point
            focusIndicator.hidden = false
            previewView.bringSubviewToFront(focusIndicator)
            UIView.animateWithDuration(0.33, delay: 0, options: [.Repeat, .Autoreverse, .CurveEaseOut],
                animations: { [unowned self] in
                    self.focusIndicator.transform = CGAffineTransformMakeScale(1.05, 1.05)
                },
                completion: nil
            )
        }

        let focusPoint = CGPoint(x: sender.locationInView(previewView).y / previewView.bounds.size.height, y: 1.0 - sender.locationInView(previewView).x / previewView.bounds.size.width)
        
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = focusPoint
                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                device.unlockForConfiguration()
                updateFocusPoint(sender.locationInView(previewView))
            } catch {}
        }
    }
    
    func shutterPressed(sender:UITapGestureRecognizer){
        shutterButton.depress()
        
        if let videoConnection = output.connectionWithMediaType(AVMediaTypeVideo) {
            output.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { [unowned self] (sampleBuffer, error) in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                let dataProvider = CGDataProviderCreateWithCFData(imageData)
                if let cgImage = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, .RenderingIntentDefault) {
                    self.capturedImage = UIImage(CGImage: cgImage, scale: 1.0, orientation: .Right)
                    if self.isUnwind {
                        self.performSegueWithIdentifier(Constants.Segues.UnwindToCreateNote, sender: self)
                    } else {
                        self.performSegueWithIdentifier(Constants.Segues.CreateNote, sender: self)
                    }
                }
            })
        }
    }
}

class ShutterButton : UIButton{
    
    private var innerCircle = InnerCircle(color: Colors.Primary)
    private var innerCircleHighlight = InnerCircle(color: UIColor.whiteColor())
    
    private struct Constants{
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
        innerCircle.backgroundColor = UIColor.clearColor()
        innerCircle.frame = frame
        
        innerCircleHighlight.backgroundColor = UIColor.clearColor()
        innerCircleHighlight.frame = frame
        innerCircleHighlight.alpha = 0
        
        addSubview(innerCircle)
        addSubview(innerCircleHighlight)
    }
    
    func reset(){
        self.innerCircleHighlight.alpha = 0
    }
    
    func press(){
        UIView.animateWithDuration(0.1, delay: 0, options: [.CurveEaseOut],
            animations: { [unowned self] in
                self.innerCircleHighlight.alpha = 0.5
            }, completion: nil)
        
    }
    
    func depress(){
        UIView.animateWithDuration(0.1, delay: 0, options: [.CurveEaseOut],
            animations: { [unowned self] in
                self.innerCircleHighlight.alpha = 0
            }, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        press()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        depress()
    }
    
    override func drawRect(rect: CGRect) {
        UIColor.whiteColor().setFill()
        createConcentricCircle(rect, percentage: 1).fill()
        
        UIColor.blackColor().setFill()
        createConcentricCircle(rect, percentage: 0.95).fill()
    }
    
    class InnerCircle : UIView{
        var color:UIColor = UIColor.clearColor()
        
        convenience init(color:UIColor){
            self.init()
            self.color = color
        }
        
        override func drawRect(rect: CGRect) {
            color.setFill()
            createConcentricCircle(rect, percentage: 0.85).fill()
        }
    }
}

extension UIView{
    func createConcentricCircle(rect:CGRect, percentage:CGFloat)->UIBezierPath {
        let path = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: rect.midX - rect.width * percentage/2, y: rect.midY - rect.height * percentage/2), size: CGSize(width: rect.width * percentage, height: rect.height * percentage)))
        return path
    }
}