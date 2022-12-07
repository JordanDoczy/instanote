import Tagged

public struct Tag: Codable, Equatable {
    public var id: Tagged<Tag, String>
    public var tag: String
    
    public init(
        id: Tagged<Tag, String>,
        tag: String
    ) {
        self.id = id
        self.tag = tag
    }
}
