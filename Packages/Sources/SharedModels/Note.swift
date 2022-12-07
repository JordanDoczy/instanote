import Foundation
import Tagged

public struct Note: Codable, Equatable, Identifiable {
    public var id: Tagged<Note, String>
    public var caption: String
    public var location: Coordinate
    public var date: Date
    
    public init(
        id: Tagged<Note, String>,
        caption: String,
        location: Coordinate,
        date: Date
    ) {
        self.id = id
        self.caption = caption
        self.location = location
        self.date = date
    }
}
