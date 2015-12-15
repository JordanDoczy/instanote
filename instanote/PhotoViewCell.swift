//
//  PhotoViewCell.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import Photos

@objc protocol PhotoViewCellDelegate {
    optional func photoViewCellSelected(cell:PhotoViewCell)
}

class PhotoViewCell: UICollectionViewCell {

    struct Constants {
        struct Selectors{
            static let Pressed:Selector = "pressed:"
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.contentMode = .ScaleAspectFill
        }
    }
    
    weak var delegate:PhotoViewCellDelegate?
   
    weak var imageFetchTask:NSURLSessionDataTask?
    var imageURL:String?=""{
        didSet{
            if imageURL == Assets.SampleImage || imageURL == Assets.DefaultImage{
                imageView.image = UIImage(named: imageURL!)
            }
            else if imageURL != nil && imageURL != oldValue, let url = NSURL(string: imageURL!){
                imageView.image = nil
                imageFetchTask?.cancel()
                imageFetchTask = UIImage.fetchImage(url) { [weak self] image, response in
                    if (response?.URL?.absoluteString == self?.imageURL){
                        self?.imageView.image = image
                    }
                }
            }
        }
    }

    private lazy var pressIndicator:UIView = { [unowned self] in
        let lazy = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        lazy.backgroundColor = Colors.Primary
        self.addSubview(lazy)
        return lazy
        }()
    
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        initialize()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize(){
        let press = UILongPressGestureRecognizer(target: self, action: Constants.Selectors.Pressed)
        press.minimumPressDuration = 0.25
        addGestureRecognizer(press)
    }
    
    func pressed(sender:UILongPressGestureRecognizer){
        if sender.state == .Began{
            pressIndicator.frame.size.width = 0
            UIView.animateWithDuration(0.33,
                animations: { [unowned self] in
                    self.pressIndicator.frame.size.width = self.frame.width
                },
                completion: { [unowned self] success in
                    if success {
                        self.delegate?.photoViewCellSelected?(self)
                    }
                })
        }
        else{
            pressIndicator.frame.size.width = 0
            pressIndicator.layer.removeAllAnimations()
        }
    }

    
}
