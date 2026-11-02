//
//  Location.swift
//  instanote
//
//  Created by Jordan Doczy on 11/29/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

nonisolated class Location: NSManagedObject {
    
    struct Constants{
        struct Relationships {
            static let Notes = "notes"
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: lat!), longitude: CLLocationDegrees(truncating: long!))
    }

    func addNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).add(note)
    }
    func removeNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).remove(note)
    }
}

// MARK: CoreData
nonisolated extension Location {

    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var notes: NSSet?

}

// MARK: Fetch Requests
nonisolated extension Location {
    static var getLocationsRequest: NSFetchRequest<Location> {
        let request = Location.fetchRequest() as! NSFetchRequest<Location>
        return request
    }
    
    static func getLocationsRequest(with coordinate: CLLocationCoordinate2D) -> NSFetchRequest<Location> {
        let request = Location.fetchRequest() as! NSFetchRequest<Location>
        // Exact match is intended: this reuses a Location saved from this same coordinate.
        request.predicate = NSPredicate(format: "lat == %@ AND long == %@",
                                        NSNumber(value: coordinate.latitude),
                                        NSNumber(value: coordinate.longitude))
        return request
    }
}
