//
//  AlgorithmRunnerTests.swift
//  AnaFinderTests
//
//  Created by Morten on 28/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import XCTest
@testable import AnaFinder

class AlgorithmRunnerTests: XCTestCase {

    let file = Bundle(for: AlgorithmRunnerTests.self).url(forResource: "wordlist-small", withExtension: "txt")!
    
    func testSmallExample() {
        let algoRunner = AlgorithmRunner(file: self.file, magicPhrase: "tapirmasten")
        let output = algoRunner.run()
        XCTAssert(!output.isEmpty)
    }
}
