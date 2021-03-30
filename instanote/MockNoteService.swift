//
//  MockNoteService.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/23/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Combine
import CoreData
import UIKit

class MockNoteService: NoteService {
    var publisher = CurrentValueSubject<[Note], Never>([])
    private var context = PersistenceFactory.getContext(type: .memory)
    
    init() {
        publisher.send(requestNotes())
    }
    
    /// used for testing
    var testNote: Note {
        createNote(caption: MockData.captions[0], photo: MockData.photos[0], loc: MockData.locations[0])
    }
    
    func createNote(caption: String, photo: String, loc: (lat: Double, long: Double)) -> Note {
        let location = Location(context: context)
        location.lat = NSNumber(value: loc.lat)
        location.long = NSNumber(value: loc.long)
        
        let note = Note(context: context)
        note.caption = caption
        note.photo = photo
        note.location = location
        
        return note
    }

    func createNote(caption: String?, uiImage: UIImage?, location: CLLocationCoordinate2D?) -> Note {
        let note = Note(context: context)
        note.caption = caption
        return note
    }
    
    func requestNotes() -> [Note] {
        var notes: [Note] = []
        for i in 0 ..< MockData.captions.count {
            notes.append(createNote(caption: MockData.captions[i], photo: MockData.photos[i], loc: MockData.locations[i]))
        }
        return notes
    }
    
    func deleteAll() {}
    func deleteNote(_ note: Note) {}
    func filter(by captionPrefix: String) -> [Note] { return [] }
    func getTags(_ searchString: String) -> [Tag]? { return nil }
    func getTags() -> [Tag]? { return nil }
    func rollback() {}
    func save() { }
    func updateNote(_ note: Note, caption: String?, uiImage: UIImage?, location: CLLocationCoordinate2D?) {}

}
