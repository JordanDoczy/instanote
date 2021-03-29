//
//  UIImage+Extensions.swift
//  instanote
//
//  Created by Jordan Doczy on 12/13/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

extension UIImage {
    
    var aspectRatio: CGFloat {
        return max(size.width/size.height, size.height/size.width)
    }

    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize = widthRatio > heightRatio ?
            CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
            CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func cropImage(toRect cropRect: CGRect) -> UIImage?
    {
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = cgImage?.cropping(to: cropRect)
        else {
            return nil
        }

        // Return image to UIImage
        let croppedImage = UIImage(cgImage: cutImageRef, scale: 1, orientation: .right)
        return croppedImage
    }
    
}
