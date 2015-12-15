//
//  ListViewCell.swift
//  instanote
//
//  Created by Jordan Doczy on 12/1/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

@objc protocol ListViewCellDelegate {
    optional func listViewCellLinkClicked(data:String)
    optional func listViewCellSelected(cell:ListViewCell)
}

class ListViewCell: UITableViewCell, UITextViewDelegate {

    struct Constants {
        struct CellIdentifiers {
            static let TagCell = "TagCell"
        }
        struct Selectors{
            static let LabelLink:Selector = "labelLink:"
            static let Pressed:Selector = "pressed:"
        }
    }
    
    private lazy var expandIndicator:UIView = {
        let lazy = UIImageView(image: UIImage(named: Assets.Expand))
        lazy.image = lazy.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        lazy.frame.size = CGSize(width: 15, height: 15)
        lazy.tintColor = UIColor.whiteColor()
        lazy.backgroundColor = Colors.PrimaryTransparent
        lazy.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        return lazy
    }()
    private lazy var pressIndicator:UIView = { [unowned self] in
        let lazy = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 5))
        lazy.backgroundColor = Colors.Primary
        self.addSubview(lazy)
        return lazy
    }()

    
    private var imageHeightConstraintOriginal:CGFloat?
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
            imageViewForThumbnail.contentMode = .ScaleAspectFill
        }
    }
    @IBOutlet weak var labelForCaption: UILabel!{
        didSet{
            labelForCaption.userInteractionEnabled = true
        }
    }
    @IBOutlet weak var labelForDate: UILabel!

    @IBOutlet weak var textViewForCaption: UITextView! {
        didSet{
            textViewForCaption.editable = false
            textViewForCaption.dataDetectorTypes = .All
            textViewForCaption.delegate = self
            textViewForCaption.text = note?.caption
            textViewForCaption.userInteractionEnabled = true
            textViewForCaption.scrollEnabled = false
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
                    
                    var attributes = [String : AnyObject]()
                    let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
                    
                    attributes[NSBackgroundColorAttributeName] = Colors.Tag
                    
                    _ = ranges.map() {
                        attributes[NSLinkAttributeName] = NSURL(string: (string as NSString).substringWithRange($0))
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
    weak var imageFetchTask:NSURLSessionDataTask?
    var imageURL:String?=""{
        didSet{
            
            if imageURL == Assets.SampleImage || imageURL == Assets.DefaultImage{
                imageViewForThumbnail.image = UIImage(named: imageURL!)
                imageViewForThumbnail.addSubview(expandIndicator)
                expandIndicator.frame.origin = CGPoint(x: imageViewForThumbnail.frame.width - expandIndicator.frame.width, y: imageViewForThumbnail.frame.height - expandIndicator.frame.height)
            }
            else if imageURL != nil && imageURL != oldValue, let url = NSURL(string: imageURL!){
                self.imageViewForThumbnail.image = nil
                imageFetchTask?.cancel()
                imageFetchTask = UIImage.fetchImage(url) { [weak self] image, response in
                    if (response?.URL?.absoluteString == self?.imageURL){
                        
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
            imageURL = note?.photo
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
    
    func pressed(sender:UILongPressGestureRecognizer){
        if sender.state == .Began{
            pressIndicator.frame.size.width = 0
            UIView.animateWithDuration(0.33,
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
    
    func increaseImageSize(scale:CGFloat){
        imageHeightConstraint.constant = imageHeightConstraint.constant * scale
        expandIndicator.hidden = true
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        delegate?.listViewCellLinkClicked?(URL.absoluteString)
        return false
    }
    
    func resetConstraints(){
        if imageHeightConstraintOriginal != nil {

            UIView.animateWithDuration(0.25,
                animations: { [weak self] in
                    if let cell = self{
                        cell.imageHeightConstraint.constant = cell.imageHeightConstraintOriginal!
                        cell.layoutIfNeeded()
                    }
                },
                completion: { [weak self] success in
                    self?.expandIndicator.hidden = false
                })
        }
    }
}


