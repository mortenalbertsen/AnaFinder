//
//  WordLoader.swift
//  AnaFinder
//
//  Created by Morten on 27/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

class WordLoader {
    static func load(fromFile file: URL, referenceWord: String) -> [String] {
        
        let contentInFile = try! String(contentsOf: file)
        let wordsInFile = contentInFile.components(separatedBy: .newlines)
        
        var acceptableWords = [String]()
        var alreadyTestedWords = Set<String>(minimumCapacity: wordsInFile.count)
        
        // Build frequencymap for reference word
        guard let frequencyMapForReferenceWord = referenceWord.frequencyMap() else {
            fatalError("Could not create frequencymap for reference word")
        }
        
        for word in wordsInFile {
            var shouldBeAdded = true
            
            if alreadyTestedWords.contains(word) {
                // Don't want to deal with duplicates
                continue
            }
            alreadyTestedWords.insert(word)
            
            if word.count > referenceWord.count || word.count == 0 {
                // Don't add words that are simply too long or are empty strings
                continue
            }
            
            
            // Optimization 3
            // Discard all combinations that have too many of one specific character
            // This can be achieved by represent each word as a 25-character vector
            // The word ABBA for instance is represented by [2,2,0,0,....,0] where zero'th index represent the number of A's in ABBA (2), the 1'st index represents the number of B's and so on.
            guard let frequencyMapForCandidateWord = word.frequencyMap() else {
                // Word contains unsupported characters
                continue
            }
            var remainingCharacters = word.count
            for (index,count) in frequencyMapForCandidateWord.enumerated() {
                if frequencyMapForReferenceWord[index] < count {
                    shouldBeAdded = false
                    break
                }
                remainingCharacters = remainingCharacters - count
                if remainingCharacters == 0 {
                    // There are no more characters to test for in word - just stop already
                    break
                }
            }
            if shouldBeAdded {
                acceptableWords.append(word)
            }
        }
        return acceptableWords.sorted()
    }
    
    /**
     Returns a list of unique destructured words
    */
    static func produceUniqueDestructuredWords(fromWords originalWords: [OriginalWord], magicPhraseLength : Int) -> [DestructuredWord] {
        var uniqueDestructuredWords = [String:DestructuredWord]()
        for word in originalWords {
            let wordSorting = String(word.sorted())
            if uniqueDestructuredWords[wordSorting] == nil {
                let destructuredWord = DestructuredWord(word: word, magicPhraseLength: magicPhraseLength)
               uniqueDestructuredWords[wordSorting] = destructuredWord
            }
        }
        return [DestructuredWord](uniqueDestructuredWords.values)
    }
}

typealias OriginalWord = String

extension String {
    func frequencyMap() -> [Int]? {
        var frequencyMap = [Int](repeating: 0, count: lookupMap.count)
        for character in self {
            guard let indexForCharacter = lookupMap[character] else {
                return nil
            }
            frequencyMap[indexForCharacter] = frequencyMap[indexForCharacter] + 1
        }
        return frequencyMap
    }
}
