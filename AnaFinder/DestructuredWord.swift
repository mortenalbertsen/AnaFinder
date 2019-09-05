//
//  DestructuredWord.swift
//  AnaFinder
//
//  Created by Morten on 31/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

struct DestructuredWord : Hashable {
    var destructuredCharacters : [Character]
    let constituents : [Int]
    let wordSorting: String
    
    init(word: String, magicPhraseLength: Int) {
        self.destructuredCharacters = [Character](repeating: " ", count: magicPhraseLength)
        destructuredCharacters.replaceSubrange(0...word.count-1, with: word.sorted())
        
        var array = [Int](repeating: 0, count: lookupMap.keys.count)
        for character in word {
            if let index = lookupMap[character] {
                let currentValue = array[index]
                array[index] = currentValue + 1
            }
        }
        self.constituents = array
        self.wordSorting = String(self.destructuredCharacters[0..<word.count])
    }
    
    func nextMissingCharacter(toMatchMagicPhrase magicPhrase: String) -> Character? {
        let magicPhraseDestructured = magicPhrase.sorted()
        for (index,neededCharacter) in magicPhraseDestructured.enumerated() {
            if index == self.wordSorting.count {
                // Stop here: We'll go out of bounds else
                return neededCharacter
            }
            if self.destructuredCharacters[index] != neededCharacter {
                return neededCharacter
            }
        }
        return nil
    }
    
    func combine(withWord otherWord: DestructuredWord) -> DestructuredWord {
        return DestructuredWord(word: self.wordSorting + otherWord.wordSorting, magicPhraseLength: self.destructuredCharacters.count)
    }
}
