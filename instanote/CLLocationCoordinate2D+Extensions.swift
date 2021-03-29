//
//  CLLocationCoordinate2D+Extensions.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/26/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
}
