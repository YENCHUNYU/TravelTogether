//
//  AlertTests.swift
//  TravelTogether
//
//  Created by User on 2023/12/25.
//

import XCTest
@testable import TravelTogether

class CustomSegmentedControlTests: XCTestCase {
// buttons數量 = button title數量
// buttonTitles = button.title
// button target數量 = 1
// button[0] titleColor = selectorTextColor
    
    func testCreateButton() {

        let segmentedControl = CustomSegmentedControl()
        let buttonTitles = ["Option 1", "Option 2", "Option 3"]
        segmentedControl.buttonTitles = buttonTitles

        segmentedControl.createButton()

        XCTAssertEqual(
            segmentedControl.buttons.count,
            buttonTitles.count, "Number of buttons should match the number of titles")

        for (index, button) in segmentedControl.buttons.enumerated() {
            XCTAssertEqual(
                button.title(for: .normal),
                buttonTitles[index], "Button title should match the expected title")
            XCTAssertEqual(button.allTargets.count, 1, "Button should have one target")
        }
        XCTAssertEqual(
            segmentedControl.buttons[0].titleColor(for: .normal),
            segmentedControl.selectorTextColor, "First button text color should match the selected color")
    }
}
