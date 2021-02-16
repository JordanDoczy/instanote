//
//  UIToggleView.swift
//  instanote
//
//  Created by Jordan Doczy on 12/7/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

@objc protocol UIToggleViewDelegate {
    @objc optional func toggleViewWillToggle()
    @objc optional func toggleViewDidToggle()
}


class UIToggleView : UIView {

    // MARK: Private Memebers
    fileprivate lazy var tap: UITapGestureRecognizer = { [unowned self] in
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleView(_:)))
        return tap
    }()
    
    fileprivate var border:CAShapeLayer?
    
    // MARK: Public API
    var delegate:UIToggleViewDelegate?
    var expandIndicator:UIView?
    
    var primaryView:UIView? {
        didSet{
            primaryView!.removeGestureRecognizer(tap)
            primaryView!.frame.size = frame.size
            primaryView!.frame.origin = CGPoint.zero
            primaryView!.layer.borderColor = Colors.LightGray.cgColor
            primaryView!.layer.borderWidth = 1.0
            
            if !subviews.contains(primaryView!) {
                addSubview(primaryView!)
            }
        }
    }
    
    var scale:CGFloat = 0.25
    
    var secondaryView:UIView?{
        didSet{
            secondaryView!.isUserInteractionEnabled = true
            secondaryView!.addGestureRecognizer(tap)
            secondaryView!.frame.size = CGSize(width: frame.size.width * scale, height: frame.size.height * scale)
            secondaryView!.frame.origin = CGPoint(x: 0, y: frame.size.height - secondaryView!.frame.size.height)
            secondaryView!.layer.borderColor = Colors.LightGray.cgColor
            secondaryView!.layer.borderWidth = 1.0

            if expandIndicator != nil{
                expandIndicator!.frame.origin = CGPoint(x: secondaryView!.frame.width - expandIndicator!.frame.width, y: 0)
                secondaryView!.addSubview(expandIndicator!)
                secondaryView!.bringSubviewToFront(expandIndicator!)
            }
            
            if !subviews.contains(secondaryView!) {
                addSubview(secondaryView!)
            }
            bringSubviewToFront(secondaryView!)
        }
    }
    

    // MARK: Overrides
    override func draw(_ rect: CGRect) {
        updateSizes()
    }
    
    
    // MARK: Internal Methods
    func updateSizes(){
        primaryView?.frame.size = frame.size
        secondaryView?.frame.size = CGSize(width: frame.size.width * scale, height: frame.size.height * scale)
        if secondaryView != nil && expandIndicator != nil {
            expandIndicator!.frame.origin = CGPoint(x: secondaryView!.frame.width - expandIndicator!.frame.width, y: 0)
        }

        if let secondaryViewHeight = secondaryView?.frame.size.height{
            secondaryView?.frame.origin = CGPoint(x: 0, y: frame.size.height - secondaryViewHeight)
        }
    }
    
    @objc func toggleView(_ sender:UITapGestureRecognizer?=nil){
        
        
        expandIndicator?.removeFromSuperview()
        border?.removeFromSuperlayer()
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut,
            animations: { [unowned self] in
                
                if let thumbnail = self.secondaryView {
                    self.delegate?.toggleViewWillToggle?()
                    thumbnail.frame.size = self.frame.size
                    thumbnail.frame.origin = CGPoint.zero
                }
                
            },
            completion: { [unowned self] success in
                let previousPrimaryView = self.primaryView
                self.primaryView = self.secondaryView
                self.secondaryView = previousPrimaryView
                self.secondaryView!.alpha = 0
                self.fadeInSecondaryView()
                self.delegate?.toggleViewDidToggle?()
            }
        )
    }
    
    func fadeInSecondaryView(){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut,
            animations: { [unowned self] in
                self.secondaryView?.alpha = 1
            },
            completion: nil
        )

    }
}
