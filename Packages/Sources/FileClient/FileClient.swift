import Dependencies
import Foundation
import UIKit

public struct FileClient {

    public var deleteImage: (String) -> ()
    public var getImage: (String) -> UIImage?
    public var saveImage: (UIImage, String) -> ()

}

import XCTestDynamicOverlay
extension FileClient: TestDependencyKey {
    static public let testValue = Self(
        deleteImage: XCTUnimplemented("\(Self.self).deleteImage"),
        getImage: XCTUnimplemented("\(Self.self).getImage", placeholder: nil),
        saveImage: XCTUnimplemented("\(Self.self).saveImage")
    )

    static public let previewValue = Self(
        deleteImage: { _ in },
        getImage: { _ in
            UIImage(systemName: "photo")
        },
        saveImage: { _, _ in }
    )
}

extension DependencyValues {
    public var fileClient: FileClient {
        get { self[FileClient.self] }
        set { self[FileClient.self] = newValue }
    }
}
