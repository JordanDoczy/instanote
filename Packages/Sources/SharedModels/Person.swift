public struct Person: Equatable {
    public var name: String
    public var age: Int
    
    public init(
        name: String,
        age: Int
    ) {
        self.name = name
        self.age = age
    }
}
