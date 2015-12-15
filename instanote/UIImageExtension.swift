//
//  UIImageExtension.swift
//  instanote
//
//  Created by Jordan Doczy on 12/13/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit


extension UIImage{
    
    var aspectRatio: CGFloat {
        return max(size.width/size.height, size.height/size.width)
    }
    
    static func fetchImage(url:NSURL,complete:(image:UIImage?, response:NSURLResponse?)->Void)->NSURLSessionDataTask {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            if data != nil{
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue()){
                    complete(image: image, response: response)
                }
            }
        }
        task.resume()
        return task
    }
    
}
