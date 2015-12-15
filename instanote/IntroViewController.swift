//
//  IntroViewController.swift
//  instanote
//
//  Created by Jordan Doczy on 12/14/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit

class IntroViewController : UIViewController{
    
    struct Constants {
        struct Segues {
            static let Home = "Home"
        }
    }
    

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    lazy var overlay:UIVisualEffectView = { [unowned self] in
         let lazy = UIVisualEffectView(frame: self.view.frame)
        lazy.backgroundColor = Colors.Primary
        self.view.addSubview(lazy)
        return lazy
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.alpha = 0.5
        labelTrailingConstraint.constant = -label.frame.width - 20
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)


        UIView.animateWithDuration(0.6, delay: 0.22, options: .CurveEaseOut,
            animations: { [unowned self] in
                self.label.alpha = 1
                self.labelTrailingConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }) { success in
                
                UIView.animateWithDuration(0.4, delay: 1, options: .CurveEaseOut,
                    animations: { [unowned self] in
                        self.label.alpha = 0
                    },
                    completion: { [unowned self] success in
                        self.performSegueWithIdentifier(Constants.Segues.Home, sender: self)
                })
                
        }

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}