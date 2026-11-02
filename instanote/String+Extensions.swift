//
//  String+Extensions.swift
//  instanote
//
//  Created by Jordan Doczy on 12/12/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation

extension String {

    /// Ranges of hashtags: one or more "#" followed by word characters, e.g. "#beach" or "##beach".
    var hashtagRanges: [Range<String.Index>] {
        ranges(of: /#+\w+/)
    }

    /// Tag names without the leading "#", in the order they appear.
    var hashtagNames: [String] {
        hashtagRanges.map { self[$0].replacingOccurrences(of: "#", with: "") }
    }
}
