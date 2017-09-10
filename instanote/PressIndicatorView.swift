//
//  PressIndicator.swift
//  instanote
//
//  Created by Jordan Doczy on 12/14/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit



class PressIndicatorView : UIView {
    
    let circleLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")

    
    var delegate:AnyObject? {
        get {
            return animation.delegate
        }
        set{
            animation.delegate = newValue as? CAAnimationDelegate
        }
    }
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize(){
        self.backgroundColor = UIColor.clear
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)

        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = Colors.PrimaryTransparent.cgColor
        circleLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75).cgColor
        circleLayer.lineWidth = 3;
        
        circleLayer.strokeEnd = 0.0
        layer.addSublayer(circleLayer)
    }
    
    func show(_ duration: TimeInterval) {
        isHidden = false
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//        animation.delegate = self
        circleLayer.strokeEnd = 1.0
        circleLayer.add(animation, forKey: "animateCircle")
    }
    
    func hide()
    {
        isHidden = true
        circleLayer.removeAllAnimations()
    }

}
