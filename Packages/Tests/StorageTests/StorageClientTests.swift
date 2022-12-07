import Dependencies
import GRDB
import Overture
import SharedModels
import Storage
import XCTest

final class StorageClientTests: XCTestCase {

    var storageClient: StorageClient!
    
    override func setUp() async throws {
        self.storageClient = update(StorageClient.liveValue) {
            $0?.database = try! Database(DatabaseQueue())
        }
    }

    func testSetUp() throws {
        try storageClient.database.writer?.read { db in
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
    
    func testSaveNoteNoTags() {
        let note = Note(
            id: "id",
            caption: "some caption",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        storageClient.save(note: note)
        
        let tags: [Tag] = storageClient.fetchAllTags()
        XCTAssertTrue(tags.isEmpty)
        
        let storedNote = storageClient.fetchAllNotes()
        XCTAssertEqual(1, storedNote.count)
    }
    
    func testSaveNoteWithTags() {
        let note = Note(
            id: "id",
            caption: "some caption #tag1 and then later #tag2",
            location: .init(latitude: 0.0, longitude: 0.0),
            date: Date(timeIntervalSinceNow: 0)
        )
        
        storageClient.save(note: note)
        
        let tags: [Tag] = storageClient.fetchAllTags()
        
        XCTAssertEqual(["tag1", "tag2"], tags.map(\.tag))
    }
    
    func testSaveNoteWithTagsThatAlreadyExist() {
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
        
        storageClient.save(note: note1)
        let tags: [Tag] = storageClient.fetchAllTags()
        XCTAssertEqual(["tag1", "tag2"], tags.map(\.tag))
        
        storageClient.save(note: note2)
        let tagsNewer: [Tag] = storageClient.fetchAllTags()
        
        XCTAssertEqual(2, storageClient.fetchAllNotes().count)
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
        
        storageClient.save(note: note1)
        storageClient.save(note: note2)

        guard let tag = storageClient.fetchTagMatching(predicate: "tag1") else {
            return XCTFail()
        }

        let notes = storageClient.fetchNotesFromTag(tag: tag)
        XCTAssertEqual(notes.map(\.id), ["id1", "id2"])
        
    }
}
