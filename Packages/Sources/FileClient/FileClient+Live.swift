import Dependencies
import Foundation
import UIKit

extension FileClient: DependencyKey {

    static public let liveValue = Self(
        deleteImage: { fileName in
            try? FileManager.default.removeItem(at: getImagePath(fileName: fileName))
        },
        getImage: { fileName in
            let path = getImagePath(fileName: fileName)
            return try? UIImage(data: Data(contentsOf: path))
        },
        saveImage: { image, fileName in
            let data = image.jpegData(compressionQuality: 0.8)
            do {
                try data?.write(to: getImagePath(fileName: fileName))
            } catch {
                print(error)
            }
        }
    )

    static func getImagePath(fileName: String) -> URL {
        let imageDirectory = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: "images", directoryHint: .isDirectory)

        try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        return imageDirectory.appending(path: fileName, directoryHint: .notDirectory)
    }

}
