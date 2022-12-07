import FileClient
import XCTest

final class FileClientTests: XCTestCase {

    func testSave() throws {
        let fileClient = FileClient.liveValue

        let url = try XCTUnwrap(Bundle.module.url(forResource: "no-parking", withExtension: "jpg"))
        let image = try XCTUnwrap(UIImage(data: Data(contentsOf: url)))

        fileClient.saveImage(image, "test.jpg")
        let testImage = fileClient.getImage("test.jpg")

        XCTAssertEqual(image.size, testImage?.size)
    }

    func testDelete() throws {
        let fileClient = FileClient.liveValue

        let url = try XCTUnwrap(Bundle.module.url(forResource: "no-parking", withExtension: "jpg"))
        let image = try XCTUnwrap(UIImage(data: Data(contentsOf: url)))

        fileClient.saveImage(image, "test.jpg")
        fileClient.deleteImage("test.jpg")
        let testImage = fileClient.getImage("test.jpg")

        XCTAssertEqual(nil, testImage)
    }
}
