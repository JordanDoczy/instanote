import Dependencies
import GRDB

public struct Database {
    public let writer: DatabaseWriter?

    public init() {
        writer = nil
    }
}

extension DependencyValues {
    public var database: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}
