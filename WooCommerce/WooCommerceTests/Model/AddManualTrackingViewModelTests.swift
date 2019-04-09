import XCTest
@testable import WooCommerce
@testable import Yosemite

final class AddManualTrackingViewModelTests: XCTestCase {
    private var subject: AddTrackingViewModel?

    private struct MockData {
        static let siteID = 1234
        static let orderID = 5678
        static let title = "Add Tracking"
        static let primaryActionTitle = "Add"
        static let sectionCount = 1
        static let trackingRows: [AddEditTrackingRow] = [.shippingProvider,
                                                         .trackingNumber,
                                                         .dateShipped,
                                                         .datePicker]
        static let provider = ShipmentTrackingProvider(siteID: 1234,
                                                       name: "A mock provider",
                                                       url: "http://somewhere.internet.com")
    }

    override func setUp() {
        super.setUp()
        subject = AddTrackingViewModel(siteID: MockData.siteID, orderID: MockData.orderID)
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func testSiteIDRemainsUnchanged() {
        XCTAssertEqual(subject?.siteID, MockData.siteID)
    }

    func testOrderIDRemainsUnchanged() {
        XCTAssertEqual(subject?.orderID, MockData.orderID)
    }

    func testTitleReturnsExpectation() {
        XCTAssertEqual(subject?.title, MockData.title)
    }

    func testPrimaryActionTitleReturnsExpectation() {
        XCTAssertEqual(subject?.primaryActionTitle, MockData.primaryActionTitle)
    }

    func testSecondaryActionTitleIsNil() {
        XCTAssertNil(subject?.secondaryActionTitle)
    }

    func testInitialTrackingNumberIsNil() {
        XCTAssertNil(subject?.trackingNumber)
    }

    func testInitialShipmentDateIsToday() {
        let date = subject?.shipmentDate

        XCTAssertEqual(date?.normalizedDate(), Date().normalizedDate())
    }

    func testSectionCountIsOne() {
        XCTAssertEqual(subject?.sections.count, MockData.sectionCount)
    }

    func testRowsMatchExpectation() {
        XCTAssertEqual(subject?.sections.first?.rows, MockData.trackingRows)
    }

    func testRowsDoesNotContainDelete() {
        let rows = subject?.sections.first?.rows
        let rowsContainsDelete = rows?.contains(.deleteTracking)

        XCTAssertFalse(rowsContainsDelete!)
    }

    func testProviderCellNameContainsProviderName() {
        subject?.shipmentProvider = MockData.provider

        let cellName = subject?.providerCellName

        XCTAssertEqual(cellName, MockData.provider.name)
    }

    func testCanCommitReturnsFalseIfProviderIsNotSet() {
        XCTAssertFalse(subject!.canCommit)
    }

    func testCanCommitReturnsFalseIfProviderIsSetButTrackingNumberIsNotSet() {
        subject?.shipmentProvider = MockData.provider

        XCTAssertFalse(subject!.canCommit)
    }

    func testCanCommitReturnsFalseIfProviderIsNotSetAndTrackingNumberIsSet() {
        subject?.trackingNumber = "1234"

        XCTAssertFalse(subject!.canCommit)
    }

    func testCanCommitReturnsTrueIfProviderAndTrackingNumberAreNotSet() {
        subject?.shipmentProvider = MockData.provider
        subject?.trackingNumber = "1234"

        XCTAssertTrue(subject!.canCommit)
    }

    func testIsAddingReturnsTrue() {
        XCTAssertTrue(subject!.isAdding)
    }

    func testIsCustomReturnsFalse() {
        XCTAssertFalse(subject!.isCustom)
    }

}