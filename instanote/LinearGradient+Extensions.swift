//
//  LinearGradient+Extensions.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/25/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
