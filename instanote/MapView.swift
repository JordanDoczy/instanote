//
//  MapView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/23/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import MapKit
import SwiftUI

struct MapView: View {

    let location: CLLocationCoordinate2D
    let title: String

    @State private var position: MapCameraPosition

    init(location: CLLocationCoordinate2D, title: String) {
        self.location = location
        self.title = title
        _position = State(initialValue: Self.position(for: location))
    }

    var body: some View {
        Map(position: $position) {
            Marker(title, coordinate: location)
                .tint(Color.primaryColor)
        }
        // A new note's location can arrive while the map is showing.
        .onChange(of: location) { _, newLocation in
            withAnimation {
                position = Self.position(for: newLocation)
            }
        }
    }

    private static func position(for location: CLLocationCoordinate2D) -> MapCameraPosition {
        .region(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)))
    }
}

#Preview {
    let location = MockData.locations[0]
    MapView(location: CLLocationCoordinate2D(latitude: location.lat, longitude: location.long),
            title: "annotation")
}
