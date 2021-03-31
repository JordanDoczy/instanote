//
//  LocationManager.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/23/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var status: CLAuthorizationStatus? {
        didSet {
            if let status = status {
                if status == .authorizedAlways || status == .authorizedWhenInUse {
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?

    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    public func requestAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func stop() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            self?.status = status
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async { [weak self] in
            self?.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
