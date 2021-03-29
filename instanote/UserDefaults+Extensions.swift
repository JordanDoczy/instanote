//
//  UserDefaults+Extensions.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/28/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    var isFirstLaunch: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: "didLaunchBefore")
        }
        set {
            UserDefaults.standard.setValue(!newValue, forKey: "didLaunchBefore")
        }
    }
    
}
