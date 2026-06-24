//
//  XPendoUITestsLaunchTests.swift
//  XPendoUITests
//
//  Created by Taha Yasin Demirci on 21.04.2026.
//

import XCTest

final class XPendoUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // Uygulamanın tüm desteklenen UI konfigürasyonlarında (light/dark mode, farklı cihaz boyutları)
    // başarıyla açıldığını doğrular ve her konfigürasyon için ekran görüntüsü kaydeder.
    // runsForEachTargetApplicationUIConfiguration = true sayesinde her tema için ayrı çalışır.
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
