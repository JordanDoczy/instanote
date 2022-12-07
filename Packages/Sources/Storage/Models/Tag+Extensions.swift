import GRDB
import SharedModels

extension Tag: FetchableRecord, PersistableRecord {
    enum Columns: String, ColumnExpression {
        case id, tag
    }
    
    static let noteTags = hasMany(NoteTag.self)
    static let notes = hasMany(Note.self, through: noteTags, using: NoteTag.note)
    
    var notesRequest: QueryInterfaceRequest<Note> {
        request(for: Tag.notes)
    }
}

public struct TagInfo: Decodable, FetchableRecord {
    var tag: Tag
    var notes: [Note]
}
