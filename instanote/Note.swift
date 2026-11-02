//
//  Note.swift
//  instanote
//
//  Created by Jordan Doczy on 11/28/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

// Entity and attribute names match the original Core Data model, so SwiftData can open
// the store the Core Data version of the app created.
@Model
final class Note {
    var caption: String?
    var date: Date?
    /// A file name in Documents, or a full URL for sample data.
    var photo: String?

    @Relationship(deleteRule: .nullify, inverse: \Location.notes)
    var location: Location?

    @Relationship(deleteRule: .nullify, inverse: \Tag.notes)
    var tags: [Tag]? = []

    init(caption: String? = nil, date: Date? = nil, photo: String? = nil) {
        self.caption = caption
        self.date = date
        self.photo = photo
    }
}

// MARK: Attributed String
@MainActor
extension Note {

    /// The caption with each hashtag highlighted and linked; the link URL is the tag text, e.g. "#beach".
    var captionText: AttributedString {
        guard let caption else { return AttributedString() }

        var text = AttributedString(caption)
        for range in caption.hashtagRanges {
            guard let lower = AttributedString.Index(range.lowerBound, within: text),
                  let upper = AttributedString.Index(range.upperBound, within: text)
            else { continue }

            text[lower..<upper].link = URL(string: String(caption[range]))
            text[lower..<upper].backgroundColor = Color.primaryColor.opacity(0.8)
        }
        return text
    }
}

// MARK: Photo
extension Note {

    var imagePath: String? {
        guard let photo = photo else { return nil }
        return FileManager.default.getFilePath(photo)
    }

    func deletePhoto() -> Bool {
        if let imagePath = imagePath, let imageURL = URL(string: imagePath) {
            return FileManager.default.deleteImage(imageURL)
        }
        return false
    }

    func savePhoto(uiImage: UIImage) -> Bool {
        guard let path = FileManager.default.saveImage(uiImage) else {
            return false
        }

        photo = path
        return true
    }
}

// MARK: Display
extension Note {

    /// Date shown under each note in the list, e.g. "Today, 9:41 AM".
    var subtitle: String? {
        date.map { Note.subtitleFormatter.string(from: $0) }
    }

    // DateFormatter is expensive to create; the list builds a subtitle per row.
    private static let subtitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}
