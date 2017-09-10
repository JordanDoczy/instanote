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
    
    static func fetchImage(_ url:URL,complete:@escaping (_ image:UIImage?, _ response:URLResponse?)->Void)->URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if data != nil{
                let image = UIImage(data: data!)
                DispatchQueue.main.async{
                    complete(image, response)
                }
            }
        }) 
        task.resume()
        return task
    }
    
}
