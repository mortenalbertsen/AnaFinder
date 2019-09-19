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
    
    
    func testForValidCombinations(ofWords words: Set<Int>) -> Set<String> {
        var combinationsOfActualOriginalWords = Set<String>()
        let orderingsOfWords = self.wrapProduceAllCombinations(fromWords: words)
        
        for combinationOfWords in orderingsOfWords {
            // Do actual lookup
            let stringForCombination = combinationOfWords.map { element in
                return self.wordLookup.filteredWords[element]
            }
            let joinedString = stringForCombination.joined(separator: " ")
            combinationsOfActualOriginalWords.insert(joinedString)
        }
        return combinationsOfActualOriginalWords
    }
    
    func wrapProduceAllCombinations(fromWords words: Set<Int>) -> [[Int]] {
        return permute(items: words)
    }
    
    // TODO: Generalize this function to be generic
    func produceAllCombinations(fromWords words: Set<Int>, outArrays: inout [Int], startIndex : Int = 0) {
        
    }
    
    /**
            Stole this from: https://stackoverflow.com/a/34969388/5670505
     */
    func permute<C: Collection>(items: C) -> [[C.Iterator.Element]] {
        var scratch = Array(items) // This is a scratch space for Heap's algorithm
        var result: [[C.Iterator.Element]] = [] // This will accumulate our result

        // Heap's algorithm
        func heap(_ n: Int) {
            if n == 1 {
                result.append(scratch)
                return
            }

            for i in 0..<n-1 {
                heap(n-1)
                let j = (n%2 == 1) ? 0 : i
                scratch.swapAt(j, n-1)
            }
            heap(n-1)
        }

        // Let's get started
        heap(scratch.count)

        // And return the result we built up
        return result
    }

    
}
