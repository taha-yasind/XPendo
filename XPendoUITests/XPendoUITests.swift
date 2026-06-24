//
//  XPendoUITests.swift
//  XPendoUITests
//
//  Created by Taha Yasin Demirci on 21.04.2026.
//

import XCTest

final class XPendoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Uygulamanın hatasız başladığını ve ilk ekranın yüklendiğini doğrular.
    // Unit test edilemeyen UI akışları için temel doğrulama noktasıdır.
    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    // Uygulamanın açılış süresini ölçer ve performans regresyonlarını tespit eder.
    // Açılış süresi önceki çalıştırmalardan belirgin şekilde uzarsa test başarısız olur.
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
