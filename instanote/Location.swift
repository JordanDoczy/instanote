//
//  Location.swift
//  instanote
//
//  Created by Jordan Doczy on 11/29/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import CoreLocation
import Foundation
import SwiftData

@Model
final class Location {
    var lat: Double? = 0.0
    var long: Double? = 0.0
    var notes: [Note]? = []

    init(coordinate: CLLocationCoordinate2D) {
        self.lat = coordinate.latitude
        self.long = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat, let long else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
