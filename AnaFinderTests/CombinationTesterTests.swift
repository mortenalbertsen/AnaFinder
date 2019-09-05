//
//  CombinationTesterTests.swift
//  AnaFinderTests
//
//  Created by Morten on 29/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import XCTest
@testable import AnaFinder

class CombinationTesterTests: XCTestCase {
    func testCombinationsAreCorrect_1() {
        let input = ["A", "B", "C",]
        let combinations = CombinationTester.produceAllCombinations(fromWords: input)
        var expectedCombinations = [[String]]()
        expectedCombinations.append(["A", "B", "C"])
        expectedCombinations.append(["A", "C", "B"])
        expectedCombinations.append(["B", "A", "C"])
        expectedCombinations.append(["B", "C", "A"])
        expectedCombinations.append(["C", "A", "B"])
        expectedCombinations.append(["C", "B", "A"])
        XCTAssertEqual(combinations, expectedCombinations)
    }
    
    
    
    // MARK: Testing against reference-hashes
    func testFindsCombination() {
        let words = Set<String>(arrayLiteral: "ta","pir", "mast", "en")
        let referenceHash = "acbdcdb17daf7d58e1c4cdb464f995ca" // md5 for "ta mast pir en"
        let combinationTester = CombinationTester(referenceHashes: Set<String>([referenceHash]))
        let validCombinations = combinationTester.testForValidCombinations(ofWords: words)
        var expectedCombinations = Set<[String]>()
        expectedCombinations.insert(["ta", "mast", "pir", "en"])
        XCTAssertEqual(validCombinations, expectedCombinations)
    }
    
    func testBuildDestructedMapping() {
        let dog = DestructuredWord(word: "dog", magicPhraseLength: 16)
        let god = DestructuredWord(word: "god", magicPhraseLength: 16)
        
        let lookup = WordLookup(filteredWords: ["dog", "god"], magicPhraseLength: 16)
        let finder = CombinationFinder(magicPhrase: "does not matter", wordLookup: lookup)
        let mapping = finder.smartMapping
        var countToWordMapping = [Int:Set<DestructuredWord>]()
        countToWordMapping[3] = Set<DestructuredWord>(arrayLiteral: dog, god)
        var expectedMapping = [Character:[Int:Set<DestructuredWord>]]()
        expectedMapping["d"] = countToWordMapping
        
        XCTAssertEqual(mapping, expectedMapping)
    }
    
    
}
