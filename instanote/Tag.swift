//
//  Tag.swift
//  instanote
//
//  Created by Jordan Doczy on 11/28/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Tag {
    /// The tag without its "#", e.g. "beach".
    var name: String?
    var notes: [Note]? = []

    init(name: String) {
        self.name = name
    }
}
