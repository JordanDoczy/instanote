//
//  ListViewCell.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

@objc protocol ListViewCellDelegate {
    @objc optional func listViewCellLinkClicked(_ data:String)
    @objc optional func listViewCellSelected(_ cell:ListViewCell)
}

class ListViewCell: UITableViewCell, UITextViewDelegate {

    struct Constants {
        struct CellIdentifiers {
            static let TagCell = "TagCell"
        }
        struct Selectors{
            static let LabelLink:Selector = "labelLink:"
            static let Pressed:Selector = #selector(ListViewCell.pressed(_:))
        }
    }
    
    fileprivate lazy var expandIndicator:UIView = {
        let lazy = UIImageView(image: UIImage(named: Assets.Expand))
        lazy.image = lazy.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        lazy.frame.size = CGSize(width: 15, height: 15)
        lazy.tintColor = UIColor.white
        lazy.backgroundColor = Colors.PrimaryTransparent
        lazy.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        return lazy
    }()
    fileprivate lazy var pressIndicator:UIView = { [unowned self] in
        let lazy = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        lazy.backgroundColor = Colors.Primary
        self.addSubview(lazy)
        return lazy
    }()

    
    fileprivate var imageHeightConstraintOriginal:CGFloat?
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!{
        didSet{
            if imageHeightConstraintOriginal == nil{
                imageHeightConstraintOriginal = imageHeightConstraint.constant
            }
        }
    }
    @IBOutlet weak var imageViewForThumbnail: UIImageView! {
        didSet{
            imageViewForThumbnail.clipsToBounds = true
            imageViewForThumbnail.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var labelForCaption: UILabel!{
        didSet{
            labelForCaption.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var labelForDate: UILabel!

    @IBOutlet weak var textViewForCaption: UITextView! {
        didSet{
            textViewForCaption.isEditable = false
            textViewForCaption.dataDetectorTypes = .all
            textViewForCaption.delegate = self
            textViewForCaption.text = note?.caption
            textViewForCaption.isUserInteractionEnabled = true
            textViewForCaption.isScrollEnabled = false
            textViewForCaption.textContainerInset = UIEdgeInsetsMake(0,-5,0,0);

        }
    }
    
    var caption:String?{
        get{
            return textViewForCaption.text ?? ""
        }
        set{
            if let string = newValue{
                
                if let ranges = string.rangesForRegex("\\#+\\w+") {
                    
                    var attributes = [String : Any]()
                    let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
                    
                    attributes[NSBackgroundColorAttributeName] = Colors.Tag
                    
                    _ = ranges.map() {
                        attributes[NSLinkAttributeName] = URL(string: (string as NSString).substring(with: $0))
                        attributedString.setAttributes(attributes, range: $0)

                    }
                    
                    textViewForCaption.attributedText = attributedString
                }
                
                
                
                
            }
        }
    }
    var date:String?{
        get{
            return labelForDate.text ?? ""
        }
        set{
            labelForDate.text = newValue
        }
    }
    weak var delegate:ListViewCellDelegate?
    weak var imageFetchTask:URLSessionDataTask?
    var imageURL:String?=""{
        didSet{
            
            if imageURL == Assets.SampleImage || imageURL == Assets.DefaultImage{
                imageViewForThumbnail.image = UIImage(named: imageURL!)
                imageViewForThumbnail.addSubview(expandIndicator)
                expandIndicator.frame.origin = CGPoint(x: imageViewForThumbnail.frame.width - expandIndicator.frame.width, y: imageViewForThumbnail.frame.height - expandIndicator.frame.height)
            }
            else if imageURL != nil && imageURL != oldValue, let url = URL(string: imageURL!){
                self.imageViewForThumbnail.image = nil
                imageFetchTask?.cancel()
                imageFetchTask = UIImage.fetchImage(url) { [weak self] image, response in
                    if (response?.url?.absoluteString == self?.imageURL){
                        
                        if let imageViewForThumbnail = self?.imageViewForThumbnail {
                            imageViewForThumbnail.image = image
                            
                            if let expandIndicator = self?.expandIndicator{
                                imageViewForThumbnail.addSubview(expandIndicator)
                                
                                expandIndicator.frame.origin = CGPoint(x: imageViewForThumbnail.frame.width - expandIndicator.frame.width, y: imageViewForThumbnail.frame.height - expandIndicator.frame.height)
                            }
                        }
                    }
                }
            }
        }
    }
    var note:Note?{
        didSet{
            caption = note?.caption
            date = note?.subtitle
            imageURL = note?.imagePath
            pressIndicator.frame.size.width = 0
        }
    }
    
    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    func pressed(_ sender:UILongPressGestureRecognizer){
        if sender.state == .began{
            pressIndicator.frame.size.width = 0
            UIView.animate(withDuration: 0.33,
                animations: { [weak self] in
                    if let cell = self{
                        cell.pressIndicator.frame.size.width = cell.frame.width
                    }
                },
                completion: { [weak self] success in
                    if success {
                        if let cell = self{
                            cell.delegate?.listViewCellSelected?(cell)
                        }
                    }
                })
        }
        else{
            pressIndicator.frame.size.width = 0
            pressIndicator.layer.removeAllAnimations()
        }
    }
    
    func increaseImageSize(_ scale:CGFloat){
        imageHeightConstraint.constant = imageHeightConstraint.constant * scale
        expandIndicator.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        delegate?.listViewCellLinkClicked?(URL.absoluteString)
        return false
    }
    
    func resetConstraints(){
        if imageHeightConstraintOriginal != nil {

            UIView.animate(withDuration: 0.25,
                animations: { [weak self] in
                    if let cell = self{
                        cell.imageHeightConstraint.constant = cell.imageHeightConstraintOriginal!
                        cell.layoutIfNeeded()
                    }
                },
                completion: { [weak self] success in
                    self?.expandIndicator.isHidden = false
                })
        }
    }
}


