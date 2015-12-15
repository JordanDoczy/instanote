//
//  FetchImageOperation.swift
//  instanote
//
//  Created by Jordan Doczy on 12/13/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

class FetchImageOperation: NSOperation {

    struct Constants{
        static let isExecuting = "isExecuting"
        static let isFinished = "isFinished"
        struct Selectors{
            static let Start:Selector = "start"
            static let Finished:Selector = "finished:"
        }
    }
    
    var imageURL:NSURL?
    var image:UIImage?
    
    required init(imageURL:NSURL){
        self.imageURL = imageURL
    }
    
    override var asynchronous:Bool {
        return true
    }
    
    var _isFinished = false
    override var finished:Bool {
        get{
            return _isFinished
        }
    }
    
    var _isExecuting = false
    override var executing:Bool {
        get{
            return _isExecuting
        }
    }
    
    override func start() {
        if self.cancelled { return }

//        if !NSThread.isMainThread() {
//            performSelectorOnMainThread(Constants.Selectors.Start, withObject: nil, waitUntilDone: false)
//            return
//        }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [unowned self] in
            self.willChangeValueForKey(Constants.isExecuting)
            self._isExecuting = true
            self.didChangeValueForKey(Constants.isExecuting)

            if let imageData = NSData(contentsOfURL: self.imageURL!) {
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.finished(imageData)
                }
            } else {
             self.failed()
            }
        }
    }
    
    func failed(){
        willChangeValueForKey(Constants.isExecuting)
        willChangeValueForKey(Constants.isFinished)
        
        _isExecuting = false
        _isFinished = true
        
        didChangeValueForKey(Constants.isExecuting)
        didChangeValueForKey(Constants.isFinished)
    }
    
    func finished(imageData:NSData){

        if self.cancelled { return }
        let imageData = NSData(contentsOfURL:imageURL!)
        
        if self.cancelled { return }
        if imageData?.length > 0 {
            image = UIImage(data:imageData!)
        }
        
        if self.cancelled { return }
        willChangeValueForKey(Constants.isExecuting)
        willChangeValueForKey(Constants.isFinished)
        
        _isExecuting = false
        _isFinished = true
        
        didChangeValueForKey(Constants.isExecuting)
        didChangeValueForKey(Constants.isFinished)
    }
    
}