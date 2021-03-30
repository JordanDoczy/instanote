//
//  NoteService.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/21/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Combine
import CoreLocation
import SwiftUI

protocol NoteService {

    var publisher: CurrentValueSubject<[Note], Never> { get }

    func createNote(caption: String?, uiImage: UIImage?, location: CLLocationCoordinate2D?) -> Note
    func deleteAll()
    func deleteNote(_ note: Note)
    func filter(by captionPrefix: String) -> [Note]
    func getTags(_ searchString: String) -> [Tag]?
    func getTags() -> [Tag]?
    func requestNotes() -> [Note]
    func rollback()
    func save()
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
