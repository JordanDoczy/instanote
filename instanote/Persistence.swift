//
//  Persistence.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/21/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import OSLog
import SwiftData

enum Persistence {

    static let schema = Schema([Note.self, Location.self, Tag.self])

    /// The Core Data version of the app stored notes in this file. SwiftData opens the same
    /// file, so notes saved by earlier versions carry over.
    static let storeURL = URL.documentsDirectory.appending(path: "SingleViewCoreData.sqlite")

    private static let logger = Logger(subsystem: "com.jordandoczy.InstaNote", category: "Persistence")

    static func makeContainer(url: URL) throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: url))
    }

    static func makeInMemoryContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true))
        } catch {
            fatalError("Couldn't create an in-memory note store: \(error)")
        }
    }

    /// Opens the store at `url`. If the file can't be read, it's renamed (not deleted) and the
    /// app starts with an empty store, rather than crashing on every launch.
    static func makeAppContainer(url: URL = storeURL) -> ModelContainer {
        do {
            return try makeContainer(url: url)
        } catch {
            logger.error("Couldn't open note store, setting it aside: \(error)")
            setAsideStore(at: url)
        }

        do {
            return try makeContainer(url: url)
        } catch {
            fatalError("Couldn't create a note store: \(error)")
        }
    }

    /// Renames the store and its SQLite side files to "<name>-unreadable-<timestamp>.sqlite".
    private static func setAsideStore(at url: URL) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let base = url.deletingPathExtension().lastPathComponent
        let directory = url.deletingLastPathComponent()

        for suffix in ["", "-wal", "-shm"] {
            let source = directory.appending(path: url.lastPathComponent + suffix)
            let destination = directory.appending(path: "\(base)-unreadable-\(timestamp).sqlite" + suffix)
            try? FileManager.default.moveItem(at: source, to: destination)
        }
    }
}
