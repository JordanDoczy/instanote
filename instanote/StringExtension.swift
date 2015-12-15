//
//  StringExtension.swift
//  instanote
//
//  Created by Jordan Doczy on 12/12/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation

extension String{
    
    func rangesForRegex(regex: String!) -> [NSRange]? {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matchesInString(self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { $0.range }
        } catch { }
        return nil
    }
    
    func matchesForRegex(regex: String!) -> [String]? {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matchesInString(self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substringWithRange($0.range)}
        } catch {}

        return nil
    }
}