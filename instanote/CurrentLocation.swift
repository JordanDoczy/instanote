//
//  CurrentLocation.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/23/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import CoreLocation

enum CurrentLocation {

    /// Asks for when-in-use permission if needed, then returns the first location fix.
    /// Returns nil if the user denies access or the task is cancelled.
    static func coordinate() async -> CLLocationCoordinate2D? {
        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }

        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if let location = update.location {
                    return location.coordinate
                }
                if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
                    return nil
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
