//
//  Tag.swift
//  instanote
//
//  Created by Jordan Doczy on 11/28/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData


class Tag: NSManagedObject {

    struct Constants{
        struct Relationships {
            static let Notes = "notes"
        }
        struct Properties {
            static let Name = "name"
        }
    }
    
    func addNote(note:Note){
        mutableSetValueForKey(Constants.Relationships.Notes).addObject(note)
    }
    func removeNote(note:Note){
        mutableSetValueForKey(Constants.Relationships.Notes).removeObject(note)
    }

    func debug(prepend:String=""){
        print(prepend + name!)
    }
    
}
