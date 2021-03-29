//
//  MockNoteService.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/23/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation

class MockNoteService: RealNoteService {
    
    init() {
        super.init(context: PersistenceFactory.getContext(type: .memory))
    }
    
    override func requestNotes() {
        MockData.CreateTestData(service: self)
        super.requestNotes()
    }
}
