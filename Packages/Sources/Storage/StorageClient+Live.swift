import Foundation
import Dependencies
import GRDB
import SharedModels

extension StorageClient: DependencyKey {

    static public var liveValue = Self(
        database: .liveValue,
        _saveNote: { database, note, tags in
            let noteTags = tags.map { tag in
                NoteTag(noteId: note.id, tagId: tag.id)
            }

            try? database.writer?.write { db in
                try note.save(db)

                try tags.forEach {
                    if try !$0.exists(db) {
                        try $0.save(db)
                    }
                }

                try noteTags.forEach {
                    try $0.save(db)
                }
            }
        },
        _fetchAllNotes: { database in
            (try? database.writer?.read { db in
                try Note.fetchAll(db)
            }) ?? []
        },
        _fetchNotesMatching: { database, predicate in
            [] // TODO: use SQL like
        },
        _fetchNotesFromTag: { database, tag in
            (try? database.writer?.read { db in
                try tag.notesRequest.fetchAll(db)
            }) ?? []
        },
        _fetchAllTags: { database in
            (try? database.writer?.read { db in
                try Tag.fetchAll(db)
            }) ?? []
        },
        _fetchTagMatching: { database, predicate in
            try? database.writer?.read { db in
                let myTag = try Tag
                    .filter(Tag.Columns.tag == predicate)
                    .fetchOne(db)

                return myTag
            }
        }
    )
}
