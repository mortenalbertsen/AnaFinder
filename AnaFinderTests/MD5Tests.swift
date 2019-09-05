//
//  MD5Tests.swift
//  AnaFinderTests
//
//  Created by Morten on 29/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import XCTest
@testable import AnaFinder

class MD5Test: XCTestCase {
    
    func testMD5IsCorrect() {
        let word = "ta mast pir en"
        let actualMd5 = word.md5()
        let expectedMD5 = "acbdcdb17daf7d58e1c4cdb464f995ca"
        XCTAssertEqual(actualMd5, expectedMD5)
    }
}
