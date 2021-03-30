//
//  EnvironmentValues+Extensions.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/29/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import SwiftUI

struct NoteServiceKey: EnvironmentKey {
    typealias Value = NoteService
    static var defaultValue: NoteService = RealNoteService(context: PersistenceFactory.getContext())
}

extension EnvironmentValues {
    var service: NoteService {
        get {
            return self[NoteServiceKey.self]
        }
        set {
            self[NoteServiceKey.self] = newValue
        }
    }
}
