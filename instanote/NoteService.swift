//
//  NoteService.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/19/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import CoreLocation
import Foundation
import Observation
import OSLog
import SwiftData
import UIKit

/// Reads and writes notes. Changes are kept in memory until `save()`, so an edit can be cancelled with `rollback()`.
@Observable
final class NoteService {

    /// Every saved note, newest first. Refreshed after each save or rollback.
    private(set) var notes: [Note] = []

    @ObservationIgnored let container: ModelContainer
    @ObservationIgnored private var context: ModelContext { container.mainContext }

    private static let logger = Logger(subsystem: "com.jordandoczy.InstaNote", category: "NoteService")

    init(container: ModelContainer) {
        self.container = container
        // Cancel relies on unsaved edits staying unsaved, so only save() writes.
        container.mainContext.autosaveEnabled = false
        refresh()
    }

    // MARK: Search

    /// Notes whose caption starts with `captionPrefix`, or that have a tag starting with it (ignoring "#"), newest first.
    func filter(by captionPrefix: String) -> [Note] {
        guard !captionPrefix.isEmpty else { return notes }

        let captionMatches = notes.filter { $0.caption?.hasPrefixIgnoringCase(captionPrefix) == true }
        let tagMatches = getTags(captionPrefix.replacingOccurrences(of: "#", with: "")).flatMap { $0.notes ?? [] }

        var seen = Set<PersistentIdentifier>()
        return (captionMatches + tagMatches)
            .filter { seen.insert($0.persistentModelID).inserted }
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }

    // MARK: Create

    func createNote(caption: String? = nil, uiImage: UIImage? = nil, location: CLLocationCoordinate2D? = nil) -> Note {
        let note = Note()
        context.insert(note)
        updateNote(note, caption: caption, uiImage: uiImage, location: location)
        return note
    }

    private func createLocation(_ coordinate: CLLocationCoordinate2D) -> Location {
        let location = Location(coordinate: coordinate)
        context.insert(location)
        return location
    }

    private func createTag(_ name: String) -> Tag? {
        guard !name.isEmpty else { return nil }
        let tag = Tag(name: name)
        context.insert(tag)
        return tag
    }

    // MARK: Update

    func updateNote(_ note: Note, caption: String? = nil, uiImage: UIImage? = nil, location: CLLocationCoordinate2D? = nil) {
        note.caption = caption
        note.date = Date()

        if let uiImage {
            // replace the old photo file with the new one
            _ = note.deletePhoto()
            _ = note.savePhoto(uiImage: uiImage)
        }

        if let caption {
            updateTags(for: note, caption: caption)
        }

        if let location, note.location?.coordinate != location {
            note.location = getLocation(location) ?? createLocation(location)
        }
    }

    private func updateTags(for note: Note, caption: String) {
        note.tags = caption.hashtagNames.compactMap { name in
            getTag(name) ?? createTag(name)
        }
    }

    // MARK: Delete

    func deleteNote(_ note: Note) {
        _ = note.deletePhoto()
        context.delete(note)
    }

    func deleteAll() {
        getNotes().forEach(deleteNote)
        getTags().forEach(context.delete)
        getLocations().forEach(context.delete)
    }

    // MARK: Fetch

    func getNotes() -> [Note] {
        fetch(FetchDescriptor<Note>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
    }

    func getLocations() -> [Location] {
        fetch(FetchDescriptor<Location>())
    }

    /// Exact match is intended: this reuses a Location saved from this same coordinate.
    func getLocation(_ coordinate: CLLocationCoordinate2D) -> Location? {
        let lat: Double? = coordinate.latitude
        let long: Double? = coordinate.longitude
        var descriptor = FetchDescriptor<Location>(predicate: #Predicate { $0.lat == lat && $0.long == long })
        descriptor.fetchLimit = 1
        return fetch(descriptor).first
    }

    func getTags() -> [Tag] {
        fetch(FetchDescriptor<Tag>())
    }

    /// Tags whose name starts with `namePrefix`, ignoring case, sorted by name.
    func getTags(_ namePrefix: String) -> [Tag] {
        fetch(FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.name)]))
            .filter { $0.name?.hasPrefixIgnoringCase(namePrefix) == true }
    }

    private func getTag(_ name: String) -> Tag? {
        let name: String? = name
        var descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == name })
        descriptor.fetchLimit = 1
        return fetch(descriptor).first
    }

    private func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) -> [T] {
        do {
            return try context.fetch(descriptor)
        } catch {
            Self.logger.error("Fetch failed: \(error)")
            return []
        }
    }

    // MARK: Save & Cancel

    func rollback() {
        context.rollback()
        refresh()
    }

    func save() {
        deleteNotesWithoutPhotos()
        deleteOrphans()

        do {
            try context.save()
        } catch {
            Self.logger.error("Save failed: \(error)")
        }
        refresh()
    }

    private func refresh() {
        notes = getNotes()
    }

    /// A note isn't useful without a photo, e.g. one created and then left empty.
    private func deleteNotesWithoutPhotos() {
        getNotes().filter { $0.photo == nil }.forEach(deleteNote)
    }

    private func deleteOrphans() {
        getTags().filter { $0.notes?.isEmpty ?? true }.forEach(context.delete)
        getLocations().filter { $0.notes?.isEmpty ?? true }.forEach(context.delete)
    }
}

private extension String {
    func hasPrefixIgnoringCase(_ prefix: String) -> Bool {
        range(of: prefix, options: [.caseInsensitive, .anchored]) != nil
    }
}
