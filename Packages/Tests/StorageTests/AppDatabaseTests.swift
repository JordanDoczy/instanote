import Dependencies
import GRDB
import Overture
import SharedModels
import Storage
import XCTest

final class AppDatabaseTests: XCTestCase {

    var appDatabase: AppDatabase!
    var writer: DatabaseWriter!
    
    override func setUp() async throws {
        self.writer = try! DatabaseQueue()
        self.appDatabase = .live(writer: writer)
    }

    func testSetUp() throws {
        try writer.read { db in
            try XCTAssert(db.tableExists("note"))
            try XCTAssertEqual(
                db.columns(in: "note").map(\.name),
                ["id", "caption", "location", "date"]
            )

            try XCTAssert(db.tableExists("tag"))
            try XCTAssertEqual(
                db.columns(in: "tag").map(\.name),
                ["id", "tag"]
            )

            try XCTAssert(db.tableExists("noteTag"))
            try XCTAssertEqual(
                db.columns(in: "noteTag").map(\.name),
                ["noteId", "tagId"]
            )
        }
    }
    
    func testSaveNoteNoTags() throws {
        let note = Note(
            id: "id",
            caption: "some caption",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        try appDatabase.save(note: note)
        
        let tags: [Tag] = try appDatabase.fetchAllTags()
        XCTAssertTrue(tags.isEmpty)
        
        let storedNote = try appDatabase.fetchAllNotes()
        XCTAssertEqual(1, storedNote.count)
    }
    
    func testSaveNoteWithTags() throws {
        let note = Note(
            id: "id",
            caption: "some caption #tag1 and then later #tag2",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        try appDatabase.save(note: note)
        
        let tags: [Tag] = try appDatabase.fetchAllTags()
        
        XCTAssertEqual(["tag1", "tag2"], tags.map(\.tag))
    }
    
    func testSaveNoteWithTagsThatAlreadyExist() throws {
        let note1 = Note(
            id: "id1",
            caption: "some caption #tag1 and then later #tag2",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        let note2 = Note(
            id: "id2",
            caption: "some caption #tag1 and then later #newTag",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        try appDatabase.save(note: note1)
        let tags: [Tag] = try appDatabase.fetchAllTags()
        XCTAssertEqual(["tag1", "tag2"], tags.map(\.tag))
        
        try appDatabase.save(note: note2)
        let tagsNewer: [Tag] = try appDatabase.fetchAllTags()
        
        XCTAssertEqual(2, try appDatabase.fetchAllNotes().count)
        XCTAssertEqual(["tag1", "tag2", "newTag"], tagsNewer.map(\.tag))
    }
    
    func testFetchNotesFromTag() throws {
        let note1 = Note(
            id: "id1",
            caption: "some caption #tag1 and then later #tag2",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        let note2 = Note(
            id: "id2",
            caption: "some caption #tag1 and then later #newTag",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        try appDatabase.save(note: note1)
        try appDatabase.save(note: note2)

        guard let tag = try appDatabase.fetchTagMatching(predicate: "tag1") else {
            return XCTFail()
        }

        let notes = try appDatabase.fetchNotesFromTag(tag: tag)
        XCTAssertEqual(notes.map(\.id), ["id1", "id2"])
    }
}
