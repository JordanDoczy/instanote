import Dependencies
import Foundation
import GRDB

extension Database: DependencyKey {
    static public var liveValue = try! Self(Self.createWriter())

    public init(_ writer: DatabaseWriter) throws {
        self.writer = writer

        var migrator = DatabaseMigrator()
        Self.registerModels(migrator: &migrator)
        try migrator.migrate(writer)
    }

    static func createWriter() throws -> DatabaseWriter {
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
