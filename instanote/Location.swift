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
import MapKit

class Location: NSManagedObject, MKAnnotation {
    
    struct Constants{
        struct Relationships {
            static let Notes = "notes"
        }
        struct Properties {
            static let Latitude = "lat"
            static let Longitude = "long"
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
extension Location {

    @NSManaged var lat: NSNumber?
    @NSManaged var long: NSNumber?
    @NSManaged var notes: NSSet?

}

// MARK: Fetch Requests
extension Location {
    static var getLocationsRequest: NSFetchRequest<Location> {
        let request = Location.fetchRequest() as! NSFetchRequest<Location>
        return request
    }
    
    static func getLocationsRequest(with coordinate: CLLocationCoordinate2D) -> NSFetchRequest<Location> {
        let request = Location.fetchRequest() as! NSFetchRequest<Location>
        let latPredicate = NSPredicate(format: "lat = %d", coordinate.latitude)
        let longPredicate = NSPredicate(format: "long = %d", coordinate.longitude)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, longPredicate])
        return request
    }
}
