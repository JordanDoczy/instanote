//
//  HelpView.swift
//  instanote
//
//  Created by Jordan Doczy on 12/13/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit


@objc protocol UIHelpViewDelegate {
    @objc optional func helpViewDidShow()
    @objc optional func helpViewDidHide()
}


class HelpView : UIVisualEffectView {
    
    struct Constants{
        struct Selectors{
            static let Close:Selector = #selector(HelpView.close(_:))
        }
    }
    
    var delegate:UIHelpViewDelegate?
    
    fileprivate var _isShowing = false
    var isShowing:Bool{
        get {
            return _isShowing
        }
    }
    
    @objc func close(_ sender:UITapGestureRecognizer){
        removeGestureRecognizer(sender)
        hide()
    }

    
    fileprivate lazy var label: UILabel = { [unowned self] in
       let label = UILabel()
        label.text = "Tap an item to see more details.\rPress and hold to edit."
        label.font = Fonts.Normal
        label.textColor = Colors.Text
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.frame = self.contentView.frame
        self.contentView.addSubview(label)
        return label
    }()
    
    func show(_ frame:CGRect){
        if isShowing{
            hide()
        }
        else{
            _isShowing = true
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: Constants.Selectors.Close))
            
            effect = nil
            isHidden = false
            
            isUserInteractionEnabled = true
            superview?.bringSubview(toFront: self)
            
            self.frame = frame
            label.frame = frame
            label.backgroundColor = Colors.Transparent
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut,
                animations: { [unowned self] in
                    self.effect = UIBlurEffect(style: .light)
                    self.label.alpha = 1
                },
                completion: { [unowned self] success in
                    self.delegate?.helpViewDidShow?()
                }
            )
        }
    }
    
    func hide(){
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut,
            animations: { [unowned self] in
                self.effect = nil
                self.label.alpha = 0
            },
            completion: { [unowned self] success in
                self.isHidden = true
                self._isShowing = false
                self.delegate?.helpViewDidHide?()
            }
        )
        
    }
    
}
