import Dependencies
import Foundation
import SharedModels
import SharedExtensions

public struct StorageClient {

    @Dependency(\.uuid) var uuid

    public var database: Database

    public var _saveNote: (Database, Note, [Tag]) -> ()

    public var _fetchAllNotes: (Database) -> [Note]
    public var _fetchNotesMatching: (Database, String) -> [Note]
    public var _fetchNotesFromTag: (Database, Tag) -> [Note]

    public var _fetchAllTags: (Database) -> [Tag]
    public var _fetchTagMatching: (Database, String) -> Tag?

    public func save(note: Note) {
        let tags = fetchTagsFromCaption(caption: note.caption)
        _saveNote(database, note, tags)
    }

    public func fetchAllNotes() -> [Note] {
        _fetchAllNotes(database)
    }

    public func fetchNotesMatching(predicate: String) -> [Note] {
        _fetchNotesMatching(database, predicate)
    }

    public func fetchNotesFromTag(tag: Tag) -> [Note] {
        _fetchNotesFromTag(database, tag)
    }

    public func fetchAllTags() -> [Tag] {
        _fetchAllTags(database)
    }

    public func fetchTagMatching(predicate: String) -> Tag? {
        _fetchTagMatching(database, predicate)
    }

    public func fetchTagsFromCaption(caption: String) -> [Tag] {
        caption.matchesForRegex("\\#+\\w+")
            .map {
                $0.replacingOccurrences(of: "#", with: "", options: .literal, range: nil)
            }
            .map {
                (_fetchTagMatching(database, $0)) ?? .init( id: "\(uuid().uuidString)", tag: $0)
            }
    }
}

import XCTestDynamicOverlay
extension StorageClient: TestDependencyKey {
    static public let testValue = Self(
        database: Database(),
        _saveNote: XCTUnimplemented("\(Self.self).saveNote"),
        _fetchAllNotes: XCTUnimplemented("\(Self.self).fetchAllNotes", placeholder: []),
        _fetchNotesMatching: XCTUnimplemented("\(Self.self).fetchNotesMatching", placeholder: []),
        _fetchNotesFromTag: XCTUnimplemented("\(Self.self).fetchNotesFromTag", placeholder: []),
        _fetchAllTags: XCTUnimplemented("\(Self.self).fetchAllTags", placeholder: []),
        _fetchTagMatching: XCTUnimplemented("\(Self.self).fetchTagMatching", placeholder: nil)
    )

    static public let previewValue = Self(
        database: Database(),
        _saveNote: { _, _, _ in },
        _fetchAllNotes: { _ in
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
        _fetchNotesMatching: { _, _ in [] },
        _fetchNotesFromTag: { _, _ in [] },
        _fetchAllTags: { _ in [] },
        _fetchTagMatching: { _, _ in nil }
    )
}

extension DependencyValues {
    public var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
