//
//  PhotoViewCell.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import Photos

protocol PhotoViewCellDelegate: class {
    func photoViewCellSelected(_ cell:PhotoViewCell)
}

class PhotoViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    weak var delegate:PhotoViewCellDelegate?
   
    weak var imageFetchTask: URLSessionDataTask?
    var imageURL:String?="" {
        didSet{
            if imageURL == Assets.SampleImage || imageURL == Assets.DefaultImage{
                imageView.image = UIImage(named: imageURL!)
            }
            else if imageURL != nil && imageURL != oldValue, let url = URL(string: imageURL!){
                imageView.image = nil
                imageFetchTask?.cancel()
                imageFetchTask = UIImage.fetchImage(url) { [weak self] image, response in
                    if (response?.url?.absoluteString == self?.imageURL){
                        self?.imageView.image = image
                    }
                }
            }
        }
    }

    fileprivate lazy var pressIndicator: UIView = { [unowned self] in
        let pressIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        pressIndicator.backgroundColor = Colors.Primary
        self.addSubview(pressIndicator)
        return pressIndicator
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
        let press = UILongPressGestureRecognizer(target: self, action: #selector(pressed(_:)))
        press.minimumPressDuration = 0.25
        addGestureRecognizer(press)
    }
    
    @objc func pressed(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            pressIndicator.frame.size.width = 0
            UIView.animate(withDuration: 0.33,
                           animations: { [weak self] in
                            if let cell = self {
                                cell.pressIndicator.frame.size.width = cell.frame.width
                            }
                },
                           completion: { [weak self] success in
                            if success, let cell = self {
                                cell.delegate?.photoViewCellSelected(cell)
                            }
            })
        case .cancelled, .failed, .ended:
            pressIndicator.layer.removeAllAnimations()
           UIView.animate(withDuration: 0.15,
                           delay: 0.25,
                           options: .curveLinear,
                           animations: { [weak self] in
                                if let cell = self {
                                    cell.pressIndicator.frame.size.width = 0
                                }
                            },
                           completion: nil)
        default: break
        }
    }

    
}
