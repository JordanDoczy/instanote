//
//  Note.swift
//  instanote
//
//  Created by Jordan Doczy on 11/28/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

nonisolated class Note: NSManagedObject, Identifiable {
    
    struct Constants{
        struct Relationships {
            static let Tags = "tags"
            static let Location = "location"
        }
    }

    override func prepareForDeletion() {
        super.prepareForDeletion()
        _ = deletePhoto()
    }

    func addTag(_ tag:Tag) {
        mutableSetValue(forKey: Constants.Relationships.Tags).add(tag)
    }
    
    func removeTag(_ tag:Tag) {
        mutableSetValue(forKey: Constants.Relationships.Tags).remove(tag)
    }
}

// MARK: Attributed String
extension Note {

    /// The caption with each hashtag highlighted and linked; the link URL is the tag text, e.g. "#beach".
    var captionText: AttributedString {
        guard let caption else { return AttributedString() }

        var text = AttributedString(caption)
        for range in caption.hashtagRanges {
            guard let lower = AttributedString.Index(range.lowerBound, within: text),
                  let upper = AttributedString.Index(range.upperBound, within: text)
            else { continue }

            text[lower..<upper].link = URL(string: String(caption[range]))
            text[lower..<upper].backgroundColor = Color.primaryColor.opacity(0.8)
        }
        return text
    }
}


// MARK: CoreData
nonisolated extension Note {

    @NSManaged var date: Date?
    @NSManaged var photo: String?
    @NSManaged var caption: String?
    @NSManaged var location: Location?
    @NSManaged var tags: NSSet?

}

// MARK: Photo
nonisolated extension Note {
    
    var imagePath: String? {
        guard let photo = photo else { return nil }
        return FileManager.default.getFilePath(photo)
    }
    
    func deletePhoto() -> Bool {
        if let imagePath = imagePath, let imageURL = URL(string: imagePath) {
            return FileManager.default.deleteImage(imageURL) // OK with dependency here, since FileManager.default is a native object
        }
        return false
    }
    
    func savePhoto(uiImage: UIImage) -> Bool {
        guard let path = FileManager.default.saveImage(uiImage) else {
            return false
        }
        
        photo = path
        return true
    }
}

// MARK: Display
extension Note {

    /// Date shown under each note in the list, e.g. "Today, 9:41 AM".
    var subtitle: String? {
        date.map { Note.subtitleFormatter.string(from: $0) }
    }

    // DateFormatter is expensive to create; the list builds a subtitle per row.
    private static let subtitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}

// MARK: Fetch Requests
nonisolated extension Note {
    
    static var getNotesRequest: NSFetchRequest<Note> {
        let request = Note.fetchRequest() as! NSFetchRequest<Note>
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.date), ascending: false)]
        return request
    }
    
    static func getNotesRequestWith(with captionPrefix: String) -> NSFetchRequest<Note> {
        let request = Note.fetchRequest() as! NSFetchRequest<Note>
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.caption), ascending: true)]
        request.predicate = NSPredicate(format: "caption BEGINSWITH[c] %@", captionPrefix)
        return request
    }
}
