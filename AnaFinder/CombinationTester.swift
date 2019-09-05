//
//  ValidCombinationFinder.swift
//  AnaFinder
//
//  Created by Morten on 27/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

class CombinationTester {
    
    let referenceHashes: Set<String>
    var counter = 1
    var testedCombinations = Set<[String]>()
    let wordLookup: WordLookup

    
    init(referenceHashes: Set<String>, wordLookup: WordLookup) {
        self.referenceHashes = referenceHashes
        self.wordLookup = wordLookup
    }
    
    
    func testForValidCombinations(ofWords words: Set<Int>) -> Set<[String]> {
        var combinationsThatMatchesReferences = Set<[String]>()
        let orderingsOfWords = self.wrapProduceAllCombinations(fromWords: words)
        
//        assert(!orderingsOfWords.isEmpty)
        let stopBag = [String](repeating: "a", count: 9)
        for combinationOfWords in orderingsOfWords {
//            assert(!self.testedCombinations.contains(combinationOfWords))
//            self.testedCombinations.insert(combinationOfWords)
            if counter % 100000 == 0 {
                Swift.print("Hello from other queue \(counter)")
            }
            counter = counter + 1
            
            // Do actual lookup
            let stringForCombination = combinationOfWords.map { element in
                return self.wordLookup.filteredWords[element]
            }
//            assert(stopBag != stringForCombination)
            
            let joinedString = stringForCombination.joined(separator: " ")
            
//            let md5ForCombination = joinedCombination.md5()
//            if referenceHashes.contains(md5ForCombination) {
//                combinationsThatMatchesReferences.insert(combinationOfWords)
//                Swift.print("We got one. \"\(joinedCombination)\" hashes to \(md5ForCombination)")
//            }
        }
        return combinationsThatMatchesReferences
    }
    
    func wrapProduceAllCombinations(fromWords words: Set<Int>) -> [[Int]] {
        if words == Set<Int>(arrayLiteral: 235, 490, 0, 1617, 1361, 1467, 1436, 1073, 1143) {
            Swift.print("Stop here!")
        }
        let totalCombinations = words.count.factorial()
        var arraysToPopulate = [[Int]](repeating: [Int](repeating: 0, count: words.count), count: totalCombinations)
        produceAllCombinations(fromWords: words, outArrays: &arraysToPopulate)
        //assert(!arraysToPopulate.contains([Int](repeating: 0, count: 9)))
        return arraysToPopulate

    }
    
    // TODO: Generalize this function to be generic
    func produceAllCombinations(fromWords words: Set<Int>, outArrays: inout [[Int]]) {
        var outerIndex = 0
        for word in words {
            var wordsCopy = words
            wordsCopy.remove(word)
            
            for index in outerIndex..<outerIndex+(words.count-1).factorial() {
                outArrays[index][0] = word
            }
            
            var innerIndex = 1
            while let next = wordsCopy.popFirst() {
                for index in outerIndex..<outerIndex+(words.count-1).factorial() {
                    outArrays[index][innerIndex] = next
                }
                innerIndex = innerIndex + 1
            }
            outerIndex = outerIndex + (words.count - 1).factorial()
        }
    }
}
