//
//  Color+Extensions.swift
//  instanote
//
//  Created by Jordan Doczy on 12/7/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import SwiftUI

extension Color {
    static let lightGray = Color(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
    static let primaryColor = Color(#colorLiteral(red: 0.8675140738, green: 0.237627387, blue: 0.6431734562, alpha: 1))
    static let primaryColorLight = Color(#colorLiteral(red: 0.9124904275, green: 0.5379670262, blue: 0.7782854438, alpha: 1))
    static let primaryColorTransparent = Color(#colorLiteral(red: 0.7647058824, green: 0.2588235294, blue: 0.5568627451, alpha: 0.9))
    static let light = Color(#colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.9215686275, alpha: 0.5))
    static let dark = Color(#colorLiteral(red: 0.3176470588, green: 0.2352941176, blue: 0.2823529412, alpha: 1))
    static let darker = Color(#colorLiteral(red: 0.1098039216, green: 0.007843137255, blue: 0.05098039216, alpha: 1))
    
    func toUIColor() -> UIColor {
        guard let cgColor = self.cgColor else { return UIColor.clear }
        return UIColor(cgColor: cgColor)
    }
}
