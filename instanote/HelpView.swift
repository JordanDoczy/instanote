//
//  HelpView.swift
//  instanote
//
//  Created by Jordan Doczy on 12/13/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit


@objc protocol UIHelpViewDelegate {
    optional func helpViewDidShow()
    optional func helpViewDidHide()
}


class HelpView : UIVisualEffectView {
    
    struct Constants{
        struct Selectors{
            static let Close:Selector = "close:"
        }
    }
    
    var delegate:UIHelpViewDelegate?
    
    private var _isShowing = false
    var isShowing:Bool{
        get {
            return _isShowing
        }
    }
    
    func close(sender:UITapGestureRecognizer){
        removeGestureRecognizer(sender)
        hide()
    }

    
    private lazy var label:UILabel = { [unowned self] in
       let lazy = UILabel()
        lazy.text = "Tap an item to see more details.\rPress and hold to edit."
        lazy.font = Fonts.Normal
        lazy.textColor = Colors.Text
        lazy.lineBreakMode = .ByWordWrapping
        lazy.numberOfLines = 0
        lazy.textAlignment = .Center
        lazy.frame.size = CGSize(width: 300, height: 100)
        self.addSubview(lazy)
        return lazy
    }()
    
    func show(frame:CGRect){
        if isShowing{
            hide()
        }
        else{
            _isShowing = true
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: Constants.Selectors.Close))
            
            effect = nil
            hidden = false
            
            userInteractionEnabled = true
            superview?.bringSubviewToFront(self)
            
            self.frame = frame
            label.frame = frame
            label.backgroundColor = Colors.Transparent
            
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut,
                animations: { [unowned self] in
                    self.effect = UIBlurEffect(style: .Light)
                    self.label.alpha = 1
                },
                completion: { [unowned self] success in
                    self.delegate?.helpViewDidShow?()
                }
            )
        }
    }
    
    func hide(){
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut,
            animations: { [unowned self] in
                self.effect = nil
                self.label.alpha = 0
            },
            completion: { [unowned self] success in
                self.hidden = true
                self._isShowing = false
                self.delegate?.helpViewDidHide?()
            }
        )
        
    }
    
}