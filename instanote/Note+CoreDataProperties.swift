//
//  Note+CoreDataProperties.swift
//  instanote
//
//  Created by Jordan Doczy on 12/5/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Note {

    @NSManaged var date: NSDate?
    @NSManaged var photo: String?
    @NSManaged var caption: String?
    @NSManaged var location: Location?
    @NSManaged var tags: NSSet?

}
