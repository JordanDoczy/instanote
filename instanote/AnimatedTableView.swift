//
//  AutoCompleteTableView.swift
//  instanote
//
//  Created by Jordan Doczy on 12/7/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit


class AnimatedTableView : UITableView  {
    
    var attachedView:UIView = UIView()

    func hide(){
        
        if hidden == false{
            layer.removeAllAnimations()
            
            UIView.animateWithDuration(0.30, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear,
                animations: { [unowned self] in
                    self.frame.origin.y = self.attachedView.frame.origin.y + self.attachedView.frame.height - self.frame.height
                    self.alpha = 0.5
                },
                completion: { [unowned self] success in
                    self.hidden = true
                })
        }

    }
    
    func show(){
        layer.removeAllAnimations()
        hidden = false
        
        UIView.animateWithDuration(0.30, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveLinear,
            animations: { [unowned self] in
                self.frame.origin.y = self.attachedView.frame.origin.y + self.attachedView.frame.height
                self.alpha = 1.0
            },
            completion: nil)
    }

}