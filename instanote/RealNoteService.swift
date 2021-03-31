//
//  Service.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/19/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class RealNoteService: NSObject, NoteService  {

    var publisher = CurrentValueSubject<[Note], Never>([])
    internal var context: NSManagedObjectContext
    
    // controller used to monitor updates and publish results
    private lazy var controller: NSFetchedResultsController<Note> = { [unowned self] in
        let controller = NSFetchedResultsController(fetchRequest: Note.getNotesRequest,
                                                    managedObjectContext: self.context,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        publisher.send(requestNotes())
    }
    
    func debug() {
        let notes = getNotes() ?? []
        let tags = getTags() ?? []
        let locations = getLocations() ?? []
        
        print("RealNoteService: notes:\(notes.count) tags:\(tags.count) locations=\(locations.count)")
    }
    
    // MARK: Request Methods
    func requestNotes() -> [Note] {
        try? controller.performFetch()
        return controller.fetchedObjects ?? []
    }

    /// single request
    func filter(by captionPrefix: String) -> [Note] {
        guard !captionPrefix.isEmpty else {
            return requestNotes()
        }

        // search by caption
        var uniqueNotes = Set<Note>(getNotes(captionPrefix) ?? [])

        // get tags that match the search
        let tags = getTags(captionPrefix.lowercased().replacingOccurrences(of: "#", with: ""))

        // get notes from tags, reduce into one array
        let notesFromTags = tags?.compactMap { $0.notes?.map { $0 as! Note } }.reduce([], { $0 + $1 })

        // combine result from caption search and tag search
        uniqueNotes = uniqueNotes.union(Set<Note>(notesFromTags ?? []))

        return Array(uniqueNotes)
    }

    
    // MARK: Create Methods
    func createLocation(_ coordinate: CLLocationCoordinate2D) ->Location {
        let location = Location(context: context)
        location.lat = coordinate.latitude as NSNumber
        location.long = coordinate.longitude as NSNumber
        return location
    }
    
    func createNote(caption: String? = nil, uiImage: UIImage? = nil, location: CLLocationCoordinate2D? = nil) -> Note {
        let note = Note(context: context)
        updateNote(note, caption: caption, uiImage: uiImage, location: location)
        return note
    }
    
    func createTag(_ tagName: String) ->Tag? {
        guard !tagName.isEmpty else { return nil }
        
        let tag = Tag(context: context)
        tag.name = tagName
        return tag
    }
    
    // MARK : Delete Methods
    func deleteAll() {
        deleteNotes()
        deleteTags()
        delelteLocations()
    }
    
    func delelteLocations() {
        _ = getLocations()?.map() { deleteObject($0) }
    }
    
    func deleteOrphanedLocations() {
        guard let locations = getLocations() else { return }
        
        for location in locations {
            if location.notes?.count == 0 {
                deleteObject(location)
            }
        }
    }
    
    func deleteNote(_ note:Note) {
        deleteObject(note)
    }
    
    func deleteEmptyNotes() {
        guard let notes = getNotes() else { return }
        
        for note in notes {
            if note.photo == nil {
                deleteNote(note)
            }
        }
    }
    
    func deleteNotes() {
        getNotes()?.forEach { deleteNote($0) }
    }
    
    func deleteObject(_ object:NSManagedObject) {
        context.delete(object)
    }

    func deleteTags() {
        _ = getTags()?.map() { deleteObject($0) }
    }
    
    func deleteOrphanedTags() {
        guard let tags = getTags() else { return }
        
        for tag in tags {
            if tag.notes?.count == 0 {
                deleteObject(tag)
            }
        }
    }
    
    // MARK: Get Methods
    func getLocation(_ coordinate: CLLocationCoordinate2D) ->Location? {
        let request = Location.getLocationsRequest(with: coordinate)
        return try? context.fetch(request).first
    }
    
    func getLocations()->[Location]? {
        let request = Location.getLocationsRequest
        return try? context.fetch(request)
    }
    
    func getNotes() -> [Note]? {
        return try? context.fetch(Note.getNotesRequest)
    }
    
    func getNotes(_ captionPrefix: String) -> [Note]? {
        let request = Note.getNotesRequestWith(with: captionPrefix)
        return try? context.fetch(request)
    }
    
    func getTag(_ tag: String) -> Tag? {
        let request = Tag.getTagRequest(with: tag)
        return try? context.fetch(request).first
    }
    
    func getTags() -> [Tag]? {
        let request = Tag.getTagsRequest
        return try? context.fetch(request)
    }
    
    func getTags(_ searchString: String) -> [Tag]? {
        let request = Tag.getTagsRequestWith(with: searchString)
        return try? context.fetch(request)
    }
    
    // MARK: Cancel Methods
    func rollback() {
        context.rollback()
    }
    
    // MARK: Save Methods
    func save() {
        do {
            // clean up
            deleteEmptyNotes()
            deleteOrphanedTags()
            deleteOrphanedLocations()
            
            try context.save()
        }
        catch _ { }
    }

    // MARK: Update Methods
    func updateLocation(for note: Note, location: CLLocationCoordinate2D) {
        note.location = getLocation(location) ?? createLocation(location)
    }

    func updateNote(_ note: Note, caption: String? = nil, uiImage: UIImage? = nil, location: CLLocationCoordinate2D? = nil) {
        note.caption = caption
        note.date = Date()
        
        if let uiImage = uiImage {
            updatePhoto(for: note, uiImage: uiImage)
        }
        
        if let caption = caption {
            updateTags(for: note, caption: caption)
        }
        
        if let location = location {
            // make sure we aren't trying to set the same coordinate
            if let coordinate = note.location?.coordinate, coordinate == location  { return }
            updateLocation(for: note, location: location)
        }
    }
    
    func updatePhoto(for note: Note, uiImage: UIImage) {
        // delete the old photo from storage
        _ = note.deletePhoto()

        // save new photo to storage
        _ = note.savePhoto(uiImage: uiImage)
    }
    
    func updateTags(for note: Note, caption: String) {
        note.tags = nil // clear all tags
        if let tags = caption.matchesForRegex("\\#+\\w+") {
            tags.forEach { item in
                let string = item.replacingOccurrences(of: "#", with: "", options: .literal, range: nil)
                
                if let tag = getTag(string) ?? createTag(string) {
                    note.addTag(tag)
                }
            }
        }
    }
}

extension RealNoteService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [Note]
        else { return }
        publisher.send(items)
    }
}
