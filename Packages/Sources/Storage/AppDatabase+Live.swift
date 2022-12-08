import Dependencies
import Foundation
import GRDB
import SharedModels

extension AppDatabase: DependencyKey {

    static public func live(writer: DatabaseWriter) -> Self {
       var migrator = DatabaseMigrator()
       Self.registerModels(migrator: &migrator)
       try? migrator.migrate(writer)

        return .init(
            writer: writer,
            _save: { database, record in
                try record.save(database)
            },
            _fetchAllNotes: Note.fetchAll,
            _fetchNotesMatching: { database, predicate in
                let request = Note.filter(Note.Columns.caption.like("%\(predicate)%"))
                return try Note.fetchAll(database, request)
            },
            _fetchNotesFromTag: { database, tag in
                try tag.notesRequest.fetchAll(database)
            },
            _fetchAllTags: Tag.fetchAll,
            _fetchTagMatching: { database, predicate in
                try Tag.filter(Tag.Columns.tag == predicate).fetchOne(database)
            }
        )
    }

    static public var liveValue = live(writer: try! createWriter())

    private static func createWriter() throws -> DatabaseWriter {
        let folderURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: "database", directoryHint: .isDirectory)

        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)

        let dbURL = folderURL.appending(component: "db.sqlite")

        return try DatabaseQueue(path: dbURL.path(percentEncoded: false))
    }

    private static func registerModels(migrator: inout DatabaseMigrator) {
        migrator.registerMigration("createNoteTable") { database in
            try database.create(table: "note") { table in
                table.column("id", .text)
                    .primaryKey()
                    .notNull()

                table.column("caption", .text).notNull()

                table.column("location", .blob).notNull()

                table.column("date", .datetime)
            }
        }

        migrator.registerMigration("createTagTable") { database in
            try database.create(table: "tag") { table in
                table.column("id", .text)
                    .primaryKey()
                    .notNull()

                table.column("tag", .text)
                    .unique(onConflict: .ignore)
                    .notNull()
            }
        }

        migrator.registerMigration("createNoteTagTable") { database in
            try database.create(table: "noteTag") { table in
                table.primaryKey(["noteId", "tagId"])

                table.column("noteId", .text)
                    .notNull()
                    .indexed()
                    .references("note", onDelete: .cascade)

                table.column("tagId", .text)
                    .notNull()
                    .indexed()
                    .references("tag", onDelete: .cascade)
            }
        }
    }
}
