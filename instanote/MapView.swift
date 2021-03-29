//
//  MapView.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/23/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {

    var location: CLLocationCoordinate2D
    var title: String

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ view: MKMapView, context: Context) {

        view.mapType = MKMapType.standard

        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        view.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title

        view.addAnnotation(annotation)
        
    }
}

struct MapView_Previews: PreviewProvider {

    static var previews: some View {
        MapView(location: CLLocationCoordinate2D(latitude: MockData.locations.first![0], longitude: MockData.locations.first![1]), title: "annotation")
        
    }
}
