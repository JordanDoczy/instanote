//
//  PhotoViewCell.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    var assetRequested:PHImageRequestID?
    let manager = PHImageManager.default()

    var asset:PHAsset?=nil{
        didSet{
            if asset != oldValue{
                let size = CGSize(width: 250, height: 250) 
                let options = PHImageRequestOptions()
                options.resizeMode = .exact
                options.deliveryMode = .highQualityFormat

                if let assetId = assetRequested{
                    manager.cancelImageRequest(assetId)
                }
                assetRequested = manager.requestImage(for: asset!, targetSize: size, contentMode: .aspectFill, options: options) { (image, data) in
                    if let id = data?[PHImageResultRequestIDKey] as? Int{
                        if self.assetRequested == Int32(id) {
                            self.imageView.image = image
                        }
                        
                    }
                }
                
            }
        }
    }
    
}
