//
//  BirthComputingTests.swift
//  BirthReminderTests
//
//  Created by Apollo Zhu on 12/9/17.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

@testable import BirthdayReminder
import XCTest

class BirthComputingTests: XCTestCase {
    func testLeapYear() {
        measure {
            XCTAssertEqual(BirthComputer.leapYear(), 2020)
            XCTAssertEqual(BirthComputer.leapYear(after: 2012), 2012)
            for year in (2013...2016) {
                XCTAssertEqual(BirthComputer.leapYear(after: year), 2016)
            }
            XCTAssertEqual(BirthComputer.leapYear(after: 2000), 2000)
            XCTAssertEqual(BirthComputer.leapYear(after: 1900), 1904)
        }
    }
}
