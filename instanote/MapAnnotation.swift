//
//  MapAnnotation.swift
//  instanote
//
//  Created by Jordan Doczy on 12/2/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation
{
    var attributes = [String:String]()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var title: String? {
        set { attributes["title"] = newValue }
        get { return attributes["title"] ?? "" }
    }
    var subtitle: String? {
        set { attributes["subtitle"] = newValue }
        get { return attributes["subtitle"] ?? "" }
    }
    var coordinate:CLLocationCoordinate2D{
        get{
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set{
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }

    override var description: String {
        return "\(latitude):\(longitude)"
    }
}
