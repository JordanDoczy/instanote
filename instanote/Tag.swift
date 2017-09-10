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
    
    func addNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).add(note)
    }
    func removeNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).remove(note)
    }

    func debug(_ prepend:String=""){
        print(prepend + name!)
    }
    
}
