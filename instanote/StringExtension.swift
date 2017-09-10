//
//  StringExtension.swift
//  instanote
//
//  Created by Jordan Doczy on 12/12/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation

extension String{
    
    func rangesForRegex(_ regex: String!) -> [NSRange]? {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { $0.range }
        } catch { }
        return nil
    }
    
    func matchesForRegex(_ regex: String!) -> [String]? {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch {}

        return nil
    }
}
