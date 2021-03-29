//
//  AppDelegateSwiftUI.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
        UITextView.appearance().backgroundColor = .clear
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = Color.darker.toUIColor()

        return true
    }
}
