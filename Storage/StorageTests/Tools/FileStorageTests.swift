import XCTest
@testable import Storage

final class FileStorageTests: XCTestCase {
    private var fileURL: URL?
    private var subject: PListFileStorage?

    override func setUp() {
        super.setUp()
        subject = PListFileStorage()
        fileURL = Bundle(for: FileStorageTests.self)
            .url(forResource: "shipment-provider", withExtension: "plist")
    }

    override func tearDown() {
        fileURL = nil
        subject = nil
        super.tearDown()
    }

    func testFileIsLoaded() {
        XCTAssertNoThrow(try subject?.data(for: fileURL!))
    }

    func testErrorIsTriggeredWhenFileFailsToLoad() {
        let url = URL(string: "http://somewhere.on.the.internet")

        XCTAssertThrowsError(try subject?.data(for: url!))
    }

    func testErrorIsTriggeredWhenWritingFails() {
        let url = URL(string: "http://somewhere.on.the.internet")
        let data = Data(count: 0)

        XCTAssertThrowsError(try subject?.write(data, to: url!))
    }

    func testErrorIsTriggeredWhenFileFailsToDelete() {
        let url = URL(string: "http://somewhere.on.the.internet")

        XCTAssertThrowsError(try subject?.deleteFile(at: url!))
    }
}
