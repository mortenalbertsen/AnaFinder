//
//  WordLoaderTests.swift
//  AnaFinderTests
//
//  Created by Morten on 28/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import XCTest
import Foundation
@testable import AnaFinder

class WordLoaderTests: XCTestCase {
    
    let testFile = Bundle(for: WordLoaderTests.self).url(forResource: "wordlist-small", withExtension: "txt")!
    
    func testFilteringOfWordsFromFile() {
        let words = WordLoader.load(fromFile: self.testFile, referenceWord: "tin")
        let expectedWords = ["ti", "ni", "in"]
        XCTAssertEqual(words, expectedWords)
    }
    
    func testFilteringOfWordsFromFile_2() {
        let words = WordLoader.load(fromFile: self.testFile, referenceWord: "tapirmasten")
        let expectedWords = ["ta", "tap", "pir", "ir", "ma", "mas", "mast", "sten", "ten", "en", "ti", "ni", "in"]
        XCTAssertEqual(words, expectedWords)
    }
}
