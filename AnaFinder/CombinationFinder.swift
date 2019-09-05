//
//  File.swift
//  AnaFinder
//
//  Created by Morten on 27/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

typealias WordIndex = Int
typealias WordLength = Int

class CombinationFinder {
    
    let magicPhrase : String
    let magicPhraseWordVector : DestructuredWord
    
    var cachedResults = [String:Set<[WordIndex]>]()
    var stopWords = Set<String>()
    var smartMapping : [Character:[Int:[DestructuredWord]]]!
    
    var foundCombinations : Set<[String]>!
    let referenceHashes = Set<String>(arrayLiteral: "e4820b45d2277f3844eac66c903e84be", "23170acc097c24edb98fc5488ab033fe", "665e5bcb0c20062fe8abaaf4628bb154")
    let wordkLookup : WordLookup
    
    var cachedOriginalWordsLookup = [[WordIndex]:Set<Set<Int>>]()
    var falsePositiveCounter = 0
    
    init(magicPhrase: String, wordLookup: WordLookup) {
        self.magicPhrase = magicPhrase
        self.magicPhraseWordVector = DestructuredWord(word: magicPhrase, magicPhraseLength: self.magicPhrase.count)
        self.wordkLookup = wordLookup
        
        self.buildWordsOfLengthForCharacterMapping()
        
    }
    
    private func buildWordsOfLengthForCharacterMapping() {
        var mapping : [Character:[Int:[DestructuredWord]]] = [:]
        for destructuredWord in self.wordkLookup.uniqueDestructuredWords {
            let firstCharacterInDestructuredWord = destructuredWord.wordSorting.first!
            if mapping[firstCharacterInDestructuredWord] == nil {
                mapping[firstCharacterInDestructuredWord] = [:]
            }
            let wordLength = destructuredWord.wordSorting.count
            if mapping[firstCharacterInDestructuredWord]![wordLength] == nil {
               mapping[firstCharacterInDestructuredWord]![wordLength] = [DestructuredWord]()
            }
            assert(!mapping[firstCharacterInDestructuredWord]![wordLength]!.contains(destructuredWord))
            mapping[firstCharacterInDestructuredWord]![wordLength]!.append(destructuredWord)
        }
        
        // Sort wordlists
        for (character, map) in mapping {
            for (wordLength, wordList) in map {
                mapping[character]![wordLength] = wordList.sorted { $0.wordSorting < $1.wordSorting }
            }
        }
        
        self.smartMapping = mapping
    }
    
    func findCombinations() -> Set<[String]> {
        Swift.print("Testing on \(self.wordkLookup.uniqueDestructuredWords.count) unique words")
        var totalFound = 0
        self.foundCombinations = Set<[String]>()
        let combinationTester = CombinationTester(referenceHashes: self.referenceHashes, wordLookup: self.wordkLookup)
        for (index,uniqueWord) in wordkLookup.uniqueDestructuredWords.enumerated() {
            let combinations = self.identifyCombinations(accumulatedWord: uniqueWord)
            Swift.print("Testing for: \(uniqueWord.wordSorting). Found \(combinations.count) combinations")
            
            var setOfSets = Set<Set<WordIndex>>(minimumCapacity: combinations.count)
            var duplictaes = [Set<WordIndex>:[[Int]]]()
            var duplicateCounter = 0
            for combination in combinations {
                let newEntry = Set<WordIndex>(combination)
                var copy = combination
                copy.append(index)
                assert(self.combinationMatchesReference(wordIndices: copy))
                if setOfSets.contains(newEntry) {
                    duplicateCounter = duplicateCounter + 1
                    if var currentValue = duplictaes[newEntry] {
                        currentValue.append(combination)
                        duplictaes[newEntry] = currentValue
                    } else {
                        duplictaes[newEntry] = [[Int]](arrayLiteral:combination)
                    }
                }
                setOfSets.insert(newEntry)
            }
            Swift.print("Duplicates: \(duplicateCounter)")
            Swift.print("Unique combinations: \(combinations.count - duplicateCounter)")
            
            for combination in combinations {
                
                var copy = combination
                copy.append(index)
//                _ = self.combinationMatchesReference(wordIndices: copy)
//                let combinationsOfOriginalWords = self.backtraceOriginalWords(fromWordIndices: copy.sorted())
//                for combinationOfOriginalWords in combinationsOfOriginalWords {
//                    let matchOfReference = combinationTester.testForValidCombinations(ofWords: combinationOfOriginalWords)
//
//                    for match in matchOfReference {
//                        self.foundCombinations.insert(match)
//                    }
//                }
            }
            Swift.print("Found \(combinations.count) for word \(uniqueWord.wordSorting)")
            
            totalFound = totalFound + combinations.count
        }
        Swift.print("Total found: \(totalFound)")
        return self.foundCombinations
    }
    
    private func combinationMatchesReference(wordIndices: [WordIndex]) -> Bool {
        let word = wordIndices.reduce("") { (accumulator, nextWordIndex) -> String in
            return accumulator + self.wordkLookup.uniqueDestructuredWords[nextWordIndex].wordSorting
        }
        let destructuredWord = DestructuredWord(word: word, magicPhraseLength: self.magicPhrase.count)
        let matches = self.matchesReference(word: destructuredWord)
        if !matches {
            Swift.print("False positive: \(falsePositiveCounter)")
            falsePositiveCounter = falsePositiveCounter + 1
        }
        return matches
    }
    
    /**
     Identifies combinations whose combined constituens matches those of magicphrase.
     In a combination the same word may appear multiple times.
     */
    func identifyCombinations(accumulatedWord: DestructuredWord, currentIndex: Int = 0) -> Set<[WordIndex]> {
        var combinationsForWord = Set<[WordIndex]>()
        if self.stopWords.contains(accumulatedWord.wordSorting) {
            return []
        }
        
        if let cachedResult = self.cachedResults[accumulatedWord.wordSorting] {
            /*
             We should not compute again from here - we know the results already
             We _do_ need to return a result though, since accumulatedWord could have been constructed
             in multiple ways, i.e. "ta" + "pir" = "tapir", but also "tap" + "ir" -> "tapir"
            */
            var filteredCachedResult = Set<[WordIndex]>()
            for combination in cachedResult {
                let lowestElement = combination.min()!
                if currentIndex <= lowestElement {
                    filteredCachedResult.insert(combination)
                }
            }
            return filteredCachedResult
        }
        
        if let nextMissingCharacterForDestructuredWord = accumulatedWord.nextMissingCharacter(toMatchMagicPhrase: self.magicPhrase) {
            guard nextMissingCharacterForDestructuredWord >= accumulatedWord.destructuredCharacters.first! else {
                // We've already explored this combination
                return []
            }
            guard let candidatesForCharacter = self.smartMapping[nextMissingCharacterForDestructuredWord] else {
                // Add to stopwords
                self.stopWords.insert(accumulatedWord.wordSorting)
                return []
            }
            let maximumLengthOfCandidateWord = self.magicPhrase.count - accumulatedWord.wordSorting.count
            for acceptableWordLength in stride(from: 1, to: maximumLengthOfCandidateWord+1, by: 1) {
                guard let candidatesOfAcceptableWordLength = candidatesForCharacter[acceptableWordLength] else {
                    continue
                }

                for candidateWord in candidatesOfAcceptableWordLength {
                    let indexForWord = self.wordkLookup.indexForWordSortingMapping[candidateWord.wordSorting]!
                    assert(self.wordkLookup.uniqueDestructuredWords[indexForWord].wordSorting == candidateWord.wordSorting)
                    if indexForWord < currentIndex {
                        continue
                    }
                                       
                    let combination = accumulatedWord.combine(withWord: candidateWord)
                    if !CombinationFinder.wordCombinationIsValid(wordCombination: combination, reference: self.magicPhraseWordVector) {
                        stopWords.insert(combination.wordSorting)
                        continue
                    }
                    
                    // Stop condition
                    if self.matchesReference(word: combination) {
                        // No gain of caching results here; we're at the bottom leaf anyways.
                        combinationsForWord.insert([WordIndex](arrayLiteral: indexForWord))
                        continue
                    }
                    
                    // Recurse
                    let combinations = self.identifyCombinations(accumulatedWord: combination, currentIndex: indexForWord)
                    if combinations.isEmpty {
                        self.stopWords.insert(combination.wordSorting)
                        continue
                    }
                    
                    for var combination in combinations {
                        combination.insert(indexForWord, at: 0)
                        combinationsForWord.insert(combination)
                    }
                    if !combinations.isEmpty {
                        self.cachedResults[combination.wordSorting] = combinations
                    }
                }
            }
        }
        return combinationsForWord
    }
    
    static func wordCombinationIsValid(wordCombination: DestructuredWord, reference: DestructuredWord) -> Bool {
        if wordCombination.wordSorting.count > reference.wordSorting.count {
            return false
        }
        for index in 0..<lookupMap.keys.count {
            if wordCombination.constituents[index] > reference.constituents[index] {
                return false
            }
        }
        return true
    }
    
    func matchesReference(word: DestructuredWord) -> Bool {
        return word.destructuredCharacters == self.magicPhraseWordVector.destructuredCharacters
    }
    
    /**
     Given a set of wordindices for destructured words, produces sets of sets of words-indices for original words
     */
    private func backtraceOriginalWords(fromWordIndices wordIndices: [WordIndex]) -> Set<Set<Int>> {
        if wordIndices.count == 1 {
            let onlyEntry = wordIndices.first!
            let wordsForIndex = self.wordkLookup.wordsSharingWordSorting[onlyEntry]
            return Set<Set<Int>>(arrayLiteral: wordsForIndex)
        }
        if let cachedResult = self.cachedOriginalWordsLookup[wordIndices] {
            return cachedResult
        }
        var returnValues = Set<Set<Int>>()
        let pickOne = wordIndices.first!
        var wordIndicesCopy = wordIndices
        wordIndicesCopy.removeFirst()
        let originalWords = self.wordkLookup.wordsSharingWordSorting[pickOne]
        for originalWord in originalWords {
            // Permutate originalWord on original words for remaining word indices
            let results = self.backtraceOriginalWords(fromWordIndices: wordIndicesCopy)
            for result in results {
                var copy = result
                copy.insert(originalWord)
                returnValues.insert(copy)
            }
        }
        self.cachedOriginalWordsLookup[wordIndices] = returnValues
        return returnValues
    }
}
