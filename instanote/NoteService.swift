//
//  NoteService.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/21/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI

protocol NoteService {
    
    var notes: [Note] { get }

    func createNote(caption: String?, uiImage: UIImage?, location: CLLocationCoordinate2D?) -> Note
    func deleteAll()
    func deleteNote(_ note: Note)
    func rollback()
    func getTags(_ searchString: String) -> [Tag]?
    func getTags() -> [Tag]?
    func save()
    func requestNotes()
    func requestNotes(with captionPrefix: String)
    func updateNote(_ note: Note, caption: String?, uiImage: UIImage?, location: CLLocationCoordinate2D?)
}

extension NoteService {
    func createNote(caption: String? = nil, uiImage: UIImage? = nil, location: CLLocationCoordinate2D? = nil) -> Note {
        createNote(caption: caption, uiImage: uiImage, location: location)
    }
    
    func updateNote(_ note: Note, caption: String? = nil, uiImage: UIImage? = nil, location: CLLocationCoordinate2D? = nil) {
        updateNote(note, caption: caption, uiImage: uiImage, location: location)
    }
}
