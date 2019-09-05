//
//  DestructuredWordTests.swift
//  AnaFinderTests
//
//  Created by Morten on 31/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import XCTest
@testable import AnaFinder

class DestructuredWordTests: XCTestCase {

    func testNextMissingCharacter_moreofsamecharacter() {
        let magicPhrase = "banana"
        let destructuredWord = DestructuredWord(word: "atom", magicPhraseLength: magicPhrase.count)
        guard let nextMissingCharacter = destructuredWord.nextMissingCharacter(toMatchMagicPhrase: magicPhrase) else {
            XCTFail("No character")
            return
        }
        // "banana" has three 'a's - "atom" has a single 'a' - we need two more 'a's
        XCTAssert(nextMissingCharacter == "a")
    }
    
    func testNextMissingCharacter() {
        let magicPhrase = "banter"
        let destructuredWord = DestructuredWord(word: "atom", magicPhraseLength: magicPhrase.count)
        guard let nextMissingCharacter = destructuredWord.nextMissingCharacter(toMatchMagicPhrase: magicPhrase) else {
            XCTFail("No character")
            return
        }
        // In atom, we have the 'a', next up is the 'b' missing in 'banter'
        XCTAssert(nextMissingCharacter == "b")
    }
}
