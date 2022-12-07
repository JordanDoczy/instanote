import GRDB
import SharedModels
import Tagged

public struct NoteTag: Codable, FetchableRecord, PersistableRecord, TableRecord {
    public var noteId: Tagged<Note, String>
    public var tagId: Tagged<Tag, String>
    
    public init(
        noteId: Tagged<Note, String>,
        tagId: Tagged<Tag, String>
    ) {
        self.noteId = noteId
        self.tagId = tagId
    }
}

extension NoteTag {
    static let note = belongsTo(Note.self)
    static let tag = belongsTo(Tag.self)
}
