//
//  PlanViewControllerTest.swift
//  TravelTogether
//
//  Created by User on 2023/12/23.
//

import XCTest

@testable import TravelTogether

class DateConversionTests: XCTestCase {

    func testChangeDateFormat_ValidDate() {
        // Arrange
        let inputDate = "2023-01-01 12:34:56 +0000"
        let expectedOutput = "2023年01月01日"

        // Act
        let planViewController = PlanViewController()
        let result = planViewController.changeDateFormat(date: inputDate)

        // Assert
        XCTAssertEqual(result, expectedOutput, "Date conversion should be correct")
    }

    func testChangeDateFormat_InvalidDate() {
        // Arrange
        let invalidDate = "InvalidDate"

        // Act
        let planViewController = PlanViewController()
        let result = planViewController.changeDateFormat(date: invalidDate)

        // Assert
        XCTAssertEqual(result, "", "Invalid date should result in an empty string")
    }
}
