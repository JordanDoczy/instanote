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
        
        if isHidden == false{
            layer.removeAllAnimations()
            
            UIView.animate(withDuration: 0.30, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear,
                animations: { [unowned self] in
                    self.frame.origin.y = self.attachedView.frame.origin.y + self.attachedView.frame.height - self.frame.height
                    self.alpha = 0.5
                },
                completion: { [unowned self] success in
                    self.isHidden = true
                })
        }

    }
    
    func show(){
        layer.removeAllAnimations()
        isHidden = false
        
        UIView.animate(withDuration: 0.30, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveLinear,
            animations: { [unowned self] in
                self.frame.origin.y = self.attachedView.frame.origin.y + self.attachedView.frame.height
                self.alpha = 1.0
            },
            completion: nil)
    }

}
