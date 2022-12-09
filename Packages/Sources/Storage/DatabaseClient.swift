import Dependencies
import Foundation
import SharedExtensions
import SharedModels

public struct DatabaseClient {

    @Dependency(\.uuid) var uuid

    public var save: (Any) throws -> ()
    public var fetchAllNotes: () throws -> [Note]
    public var fetchNotesMatching: (String) throws -> [Note]
    public var fetchNotesFromTag: (Tag) throws -> [Note]
    public var fetchAllTags: () throws -> [Tag]
    public var fetchTagMatching: (String) throws -> Tag?

    public func save(note: Note) throws {
        try save(note)

        try fetchOrCreateTagsFromCaption(caption: note.caption)
            .forEach { tag in
                try save(tag)
                try save(NoteTag(noteId: note.id, tagId: tag.id))
            }
    }

    public func fetchOrCreateTagsFromCaption(caption: String) throws -> [Tag] {
        try caption.matchesForRegex("\\#+\\w+")
            .map {
                $0.replacingOccurrences(of: "#", with: "", options: .literal, range: nil)
            }
            .map {
                (try fetchTagMatching($0)) ?? .init( id: "\(uuid().uuidString)", tag: $0)
            }
    }
}

import XCTestDynamicOverlay
extension DatabaseClient: TestDependencyKey {
    static public let testValue = Self(
        save: XCTUnimplemented("\(Self.self).save"),
        fetchAllNotes: XCTUnimplemented("\(Self.self).fetchAllNotes", placeholder: []),
        fetchNotesMatching: XCTUnimplemented("\(Self.self).fetchNotesMatching", placeholder: []),
        fetchNotesFromTag: XCTUnimplemented("\(Self.self).fetchNotesFromTag", placeholder: []),
        fetchAllTags: XCTUnimplemented("\(Self.self).fetchAllTags", placeholder: []),
        fetchTagMatching: XCTUnimplemented("\(Self.self).fetchTagMatching", placeholder: nil)
    )

    static public let previewValue = Self(
        save: { _ in },
        fetchAllNotes: {
            [
                .init(
                    id: "id1",
                    caption: "Here's a test note.",
                    location: .init(latitude: 0, longitude: 0),
                    date: .now),
                .init(
                    id: "id2",
                    caption: "Here's another note with some #tags in the #message",
                    location: .init(latitude: 0, longitude: 0),
                    date: .now)
            ]
        },
        fetchNotesMatching: { _ in [] },
        fetchNotesFromTag: { _ in [] },
        fetchAllTags: { [] },
        fetchTagMatching: { _ in nil }
    )
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
