//
//  ImageViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/8/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

class ImageViewController : UIViewController, NoteDataSource, UIScrollViewDelegate {
    
    // MARK: NoteDataSource
    var note:Note?

    // MARK: Private Memebers
    fileprivate struct Constants{
        struct Selectors{
            static let DoubleTap:Selector = #selector(ImageViewController.doubleTap(_:))
            static let Pinch:Selector = "pinch:"
        }
    }
    
    fileprivate lazy var imageView:UIImageView = {
        let lazy = UIImageView()
        return lazy
    }()

    // MARK: IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet {
            scrollView.delegate = self
        }
    }
    
    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if note != nil { addPhoto() }

        let tap = UITapGestureRecognizer(target: self, action: Constants.Selectors.DoubleTap)
        tap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tap)
    }
    
    // MARK: Overrides
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: UIGestureRecognizers
    func doubleTap(_ sender:UITapGestureRecognizer){
        
        let pointInView = sender.location(in: imageView)
        let zoomScale = scrollView.zoomScale > scrollView.minimumZoomScale ? scrollView.minimumZoomScale :scrollView.maximumZoomScale
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / zoomScale
        let h = scrollViewSize.height / zoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h);
        scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    // MARK: ScrollView Protocol
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    // MARK: Private Methods
    fileprivate func addPhoto(){
        if let imageURLString = note!.imagePath{
            if imageURLString == Assets.SampleImage || imageURLString == Assets.DefaultImage{
                setImage(UIImage(named: imageURLString)!)
            }
            else if let imageURL = URL(string: imageURLString){
                UIImage.fetchImage(imageURL) { [weak self] image, response in
                    if image != nil{
                        self?.setImage(image!)
                    }
                }
            }
        }
        
        scrollView.addSubview(imageView)
    }
    
    
    fileprivate func setImage(_ image:UIImage){
        imageView.image = image
        imageView.frame.size = image.size
        
        let scaleWidth = scrollView.frame.size.width / imageView.frame.size.width
        let scaleHeight = scrollView.frame.size.height / imageView.frame.size.height
        let minScale = min(scaleWidth, scaleHeight);
        
        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = minScale;
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        centerScrollViewContents()
    }
    
    fileprivate func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    
}
