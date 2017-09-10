//
//  FetchImageOperation.swift
//  instanote
//
//  Created by Jordan Doczy on 12/13/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FetchImageOperation: Operation {

    struct Constants{
        static let isExecuting = "isExecuting"
        static let isFinished = "isFinished"
        struct Selectors{
            static let Start:Selector = #selector(Operation.start)
            static let Finished:Selector = #selector(FetchImageOperation.finished(_:))
        }
    }
    
    var imageURL:URL?
    var image:UIImage?
    
    required init(imageURL:URL){
        self.imageURL = imageURL
    }
    
    override var isAsynchronous:Bool {
        return true
    }
    
    var _isFinished = false
    override var isFinished:Bool {
        get{
            return _isFinished
        }
    }
    
    var _isExecuting = false
    override var isExecuting:Bool {
        get{
            return _isExecuting
        }
    }
    
    override func start() {
        if self.isCancelled { return }

//        if !NSThread.isMainThread() {
//            performSelectorOnMainThread(Constants.Selectors.Start, withObject: nil, waitUntilDone: false)
//            return
//        }
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [unowned self] in
            self.willChangeValue(forKey: Constants.isExecuting)
            self._isExecuting = true
            self.didChangeValue(forKey: Constants.isExecuting)

            if let imageData = try? Data(contentsOf: self.imageURL!) {
                DispatchQueue.main.async { [unowned self] in
                    self.finished(imageData)
                }
            } else {
             self.failed()
            }
        }
    }
    
    func failed(){
        willChangeValue(forKey: Constants.isExecuting)
        willChangeValue(forKey: Constants.isFinished)
        
        _isExecuting = false
        _isFinished = true
        
        didChangeValue(forKey: Constants.isExecuting)
        didChangeValue(forKey: Constants.isFinished)
    }
    
    func finished(_ imageData:Data){

        if self.isCancelled { return }
        let imageData = try? Data(contentsOf: imageURL!)
        
        if self.isCancelled { return }
        if imageData?.count > 0 {
            image = UIImage(data:imageData!)
        }
        
        if self.isCancelled { return }
        willChangeValue(forKey: Constants.isExecuting)
        willChangeValue(forKey: Constants.isFinished)
        
        _isExecuting = false
        _isFinished = true
        
        didChangeValue(forKey: Constants.isExecuting)
        didChangeValue(forKey: Constants.isFinished)
    }
    
}
