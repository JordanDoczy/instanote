//
//  LegacyStoreTests.swift
//  InstaNoteTests
//

import CoreData
import Foundation
import SwiftData
import Testing
@testable import instanote

/// Notes saved by the Core Data version of the app must still open after the move to SwiftData.
/// `LegacyCoreDataModel/instanote.xcdatamodeld` is the model that version shipped with.
struct LegacyStoreTests {

    @Test func swiftDataOpensAStoreWrittenByTheCoreDataVersion() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appending(path: "SingleViewCoreData.sqlite")
        let savedDate = Date(timeIntervalSince1970: 1_600_000_000)

        try writeLegacyStore(at: storeURL) { context in
            let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
            location.setValue(20.7984, forKey: "lat")
            location.setValue(-156.3319, forKey: "long")

            let tag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context)
            tag.setValue("hula", forKey: "name")

            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context)
            note.setValue("Aloha #hula", forKey: "caption")
            note.setValue(savedDate, forKey: "date")
            note.setValue("legacy-photo.jpg", forKey: "photo")
            note.setValue(location, forKey: "location")
            note.mutableSetValue(forKey: "tags").add(tag)
        }

        let container = try Persistence.makeContainer(url: storeURL)
        let notes = try container.mainContext.fetch(FetchDescriptor<Note>())

        let note = try #require(notes.first)
        #expect(notes.count == 1)
        #expect(note.caption == "Aloha #hula")
        #expect(note.date == savedDate)
        #expect(note.photo == "legacy-photo.jpg")
        #expect(note.tags?.compactMap(\.name) == ["hula"])
        #expect(note.location?.lat == 20.7984)
        #expect(note.location?.long == -156.3319)
    }

    @Test func unreadableStoreIsSetAsideInsteadOfDeleted() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appending(path: "SingleViewCoreData.sqlite")
        try Data("not a database".utf8).write(to: storeURL)

        let container = Persistence.makeAppContainer(url: storeURL)

        #expect(try container.mainContext.fetch(FetchDescriptor<Note>()).isEmpty)
        let fileNames = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        let setAside = try #require(fileNames.first { $0.hasPrefix("SingleViewCoreData-unreadable-") && $0.hasSuffix(".sqlite") })
        #expect(try Data(contentsOf: directory.appending(path: setAside)) == Data("not a database".utf8))
    }

    // MARK: Fixtures

    private final class BundleToken {}

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    /// Creates a SQLite store with the Core Data model, adds objects, saves, and closes it.
    private func writeLegacyStore(at url: URL, populate: (NSManagedObjectContext) -> Void) throws {
        let modelURL = try #require(Bundle(for: BundleToken.self).url(forResource: "instanote", withExtension: "momd"))
        let model = try #require(NSManagedObjectModel(contentsOf: modelURL))
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try coordinator.addPersistentStore(type: .sqlite, at: url)

        let context = NSManagedObjectContext(.mainQueue)
        context.persistentStoreCoordinator = coordinator
        populate(context)
        try context.save()
        try coordinator.remove(store)
    }
}
