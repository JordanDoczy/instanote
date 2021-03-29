//
//  Note.swift
//  instanote
//
//  Created by Jordan Doczy on 11/28/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import SwiftUI

class Note: NSManagedObject, Identifiable {
    
    struct Constants{
        struct Relationships {
            static let Tags = "tags"
            static let Location = "location"
        }
        struct Properties {
            static let Caption = "caption"
            static let Date = "date"
            static let Photo = "photo"
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
    
    var captionFormatted: NSMutableAttributedString? {
        guard let caption = caption,
              let ranges = caption.rangesForRegex("\\#+\\w+") else {
            return nil
        }
        
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.font] = UIFont.preferredFont(forTextStyle: .body)
        attributes[NSAttributedString.Key.foregroundColor] = UIColor.white
        let attributedString = NSMutableAttributedString(string: caption, attributes: attributes)

        _ = ranges.map() {
            attributes[.link] = URL(string: (caption as NSString).substring(with: $0))
            attributes[.backgroundColor] = Color.primaryColor.toUIColor().withAlphaComponent(0.8)
            attributedString.setAttributes(attributes, range: $0)
        }

        return attributedString
    }
}


// MARK: CoreData
extension Note {

    @NSManaged var date: Date?
    @NSManaged var photo: String?
    @NSManaged var caption: String?
    @NSManaged var location: Location?
    @NSManaged var tags: NSSet?

}

// MARK: Photo
extension Note {
    
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

// MARK: MKAnnotation
extension Note: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    var title: String? {
        return caption != nil ? caption : ""

    }
    
    var subtitle: String? {
        func formateDate(_ date:Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            dateFormatter.doesRelativeDateFormatting = true
            return dateFormatter.string(from: date)
        }
        
        let str:String? = date != nil ? formateDate(date! as Date) : nil
        return str != title ? str : nil
    }

}

// MARK: Fetch Requests
extension Note {
    
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
