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
    
    func close(_ sender:UITapGestureRecognizer){
        removeGestureRecognizer(sender)
        hide()
    }

    
    fileprivate lazy var label:UILabel = { [unowned self] in
       let lazy = UILabel()
        lazy.text = "Tap an item to see more details.\rPress and hold to edit."
        lazy.font = Fonts.Normal
        lazy.textColor = Colors.Text
        lazy.lineBreakMode = .byWordWrapping
        lazy.numberOfLines = 0
        lazy.textAlignment = .center
        lazy.frame.size = CGSize(width: 300, height: 100)
        self.addSubview(lazy)
        return lazy
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
