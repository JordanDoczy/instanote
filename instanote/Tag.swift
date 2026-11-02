//
//  Tag.swift
//  instanote
//
//  Created by Jordan Doczy on 11/28/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData


nonisolated class Tag: NSManagedObject {

    struct Constants{
        struct Relationships {
            static let Notes = "notes"
        }
    }
    
    func addNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).add(note)
    }
    func removeNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).remove(note)
    }
}

// MARK: CoreData
nonisolated extension Tag {

    @NSManaged var name: String?
    @NSManaged var notes: NSSet?

}

// MARK: Fetch Requests
nonisolated extension Tag {
    static func getTagRequest(with name: String) -> NSFetchRequest<Tag> {
        let request = Tag.fetchRequest() as! NSFetchRequest<Tag>
        request.predicate = NSPredicate(format: "name = %@", name)
        return request
    }

    static var getTagsRequest: NSFetchRequest<Tag> {
        let request = Tag.fetchRequest() as! NSFetchRequest<Tag>
        return request
    }
    
    static func getTagsRequestWith(with namePrefix: String) -> NSFetchRequest<Tag> {
        let request = Tag.fetchRequest() as! NSFetchRequest<Tag>
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
        request.predicate = NSPredicate(format: "name BEGINSWITH[c] %@", namePrefix)
        return request
    }
}

