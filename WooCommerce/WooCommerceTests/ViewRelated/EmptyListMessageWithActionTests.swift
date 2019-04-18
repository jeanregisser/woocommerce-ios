import XCTest
@testable import WooCommerce

final class EmptyListMessageWithActionTests: XCTestCase {
    private var subject: EmptyListMessageWithActionView?

    private struct Expectations {
        static let message = "Yo!"
        static let buttonMessage = "Semite!"
    }

    override func setUp() {
        let nib = Bundle.main.loadNibNamed("EmptyListMessageWithActionView", owner: self, options: nil)
        subject = nib?.first as? EmptyListMessageWithActionView
        super.setUp()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func testMessageLabelRendersMessage() {
        subject?.messageText = Expectations.message

        XCTAssertEqual(subject?.getMessageLabel().text, Expectations.message)
    }

    func testButtonLabelRendersMessage() {
        subject?.actionText = Expectations.buttonMessage

        XCTAssertEqual(subject?.getButtonLabel().text, Expectations.buttonMessage)
    }

    func testBackgroundStyle() {
        XCTAssertEqual(subject?.backgroundColor, StyleManager.tableViewBackgroundColor)
    }

    func testMessageLabelStyle() {
        let label = subject?.getMessageLabel()

        XCTAssertEqual(label?.textAlignment, NSTextAlignment.center)
        XCTAssertEqual(label?.font, UIFont.body)
        XCTAssertEqual(label?.textColor, StyleManager.wooGreyMid)
    }

    func testActionLabelStyle() {
        let label = subject?.getButtonLabel()

        XCTAssertEqual(label?.font, UIFont.body)
        XCTAssertEqual(label?.textColor, StyleManager.defaultTextColor)
    }

    func testActionButtonStyle() {
        let button = subject?.getButton()

        XCTAssertEqual(button?.backgroundColor, .white)
    }
}
