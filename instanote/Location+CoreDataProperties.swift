//
//  Location+CoreDataProperties.swift
//  instanote
//
//  Created by Jordan Doczy on 11/30/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var notes: NSSet?

}
