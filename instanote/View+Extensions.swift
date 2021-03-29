//
//  View+Extensions.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/12/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
