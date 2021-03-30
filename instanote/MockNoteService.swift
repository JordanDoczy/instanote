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
    
    // TODO: fix?
    func createNote(caption: String?, uiImage: UIImage?, location: CLLocationCoordinate2D?) -> Note {
        let note = Note(context: context)
        note.caption = caption
        return note
    }
    
    func deleteAll() {}
    
    func deleteNote(_ note: Note) {}
    
    func rollback() {}
    
    func getTags(_ searchString: String) -> [Tag]? { return nil }
    
    func getTags() -> [Tag]? { return nil }
    
    func save() { }
    
    func requestNotes() -> [Note] {
        var notes: [Note] = []
        
        for i in 0 ..< MockData.firstPageCaptions.count {
            let location = Location(context: context)
            location.lat = NSNumber(value: MockData.firstPageLocations[i][0])
            location.long = NSNumber(value: MockData.firstPageLocations[i][1])
            
            let note = Note(context: context)
            note.caption = MockData.firstPageCaptions[i]
            note.photo = MockData.firstPagePhotos[i]
            note.location = location
            
            notes.append(note)
        }

        return notes
    }
    
    func filter(by captionPrefix: String) -> [Note] {
        return []
    }
    


}
