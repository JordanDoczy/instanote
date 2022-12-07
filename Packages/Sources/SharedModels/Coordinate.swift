import CoreLocation
import Foundation

public struct Coordinate: Equatable, Codable {
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
