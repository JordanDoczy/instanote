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
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat!), longitude: CLLocationDegrees(long!))
    }

    func addNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).add(note)
    }
    func removeNote(_ note:Note){
        mutableSetValue(forKey: Constants.Relationships.Notes).remove(note)
    }
    func debug(_ prepend:String=""){
        if lat != nil && long != nil {
            print(prepend + "\(lat!)" + ":" + "\(long!)")
        }
    }

}
