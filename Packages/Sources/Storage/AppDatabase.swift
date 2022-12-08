import Dependencies
import Foundation
import GRDB
import SharedExtensions
import SharedModels

public struct AppDatabase {

    @Dependency(\.uuid) var uuid

    var writer: DatabaseWriter

    private var reader: DatabaseReader {
        writer
    }

    var _save: (Database, PersistableRecord) throws -> ()
    var _fetchAllNotes: (Database) throws -> [Note]
    var _fetchNotesMatching: (Database, String) throws -> [Note]
    var _fetchNotesFromTag: (Database, Tag) throws -> [Note]
    var _fetchAllTags: (Database) throws -> [Tag]
    var _fetchTagMatching: (Database, String) throws -> Tag?

    public func save(note: Note) throws {
        let tags = try fetchOrCreateTagsFromCaption(caption: note.caption)

        try writer.write { database in
            try _save(database, note)

            try tags.forEach { tag in
                if try !tag.exists(database) {
                    try _save(database, tag)
                }

                try _save(database, NoteTag(noteId: note.id, tagId: tag.id))
            }
        }
    }
}

// Public API
extension AppDatabase {
    public func fetchAllNotes() throws -> [Note] {
        try reader.read {
            try _fetchAllNotes($0)
        }
    }

    public func fetchNotesMatching(predicate: String) throws -> [Note] {
        try reader.read {
            try _fetchNotesMatching($0, predicate)
        }
    }

    public func fetchNotesFromTag(tag: Tag) throws -> [Note] {
        try reader.read {
            try _fetchNotesFromTag($0, tag)
        }
    }

    public func fetchAllTags() throws -> [Tag] {
        try reader.read {
            try _fetchAllTags($0)
        }
    }

    public func fetchTagMatching(predicate: String) throws -> Tag? {
        try reader.read {
            try _fetchTagMatching($0, predicate)
        }
    }

    public func fetchOrCreateTagsFromCaption(caption: String) throws -> [Tag] {
        try caption.matchesForRegex("\\#+\\w+")
            .map {
                $0.replacingOccurrences(of: "#", with: "", options: .literal, range: nil)
            }
            .map {
                (try fetchTagMatching(predicate: $0)) ?? .init( id: "\(uuid().uuidString)", tag: $0)
            }
    }
}

import XCTestDynamicOverlay
extension AppDatabase: TestDependencyKey {
    static public let testValue = Self(
        writer: try! DatabaseQueue(),
        _save: XCTUnimplemented("\(Self.self).save"),
        _fetchAllNotes: XCTUnimplemented("\(Self.self).fetchAllNotes", placeholder: []),
        _fetchNotesMatching: XCTUnimplemented("\(Self.self).fetchNotesMatching", placeholder: []),
        _fetchNotesFromTag: XCTUnimplemented("\(Self.self).fetchNotesFromTag", placeholder: []),
        _fetchAllTags: XCTUnimplemented("\(Self.self).fetchAllTags", placeholder: []),
        _fetchTagMatching: XCTUnimplemented("\(Self.self).fetchTagMatching", placeholder: nil)
    )

    static public let previewValue = Self(
        writer: try! DatabaseQueue(),
        _save: { _, _ in },
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
    public var database: AppDatabase {
        get { self[AppDatabase.self] }
        set { self[AppDatabase.self] = newValue }
    }
}
