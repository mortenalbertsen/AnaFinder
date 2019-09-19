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
    let allowedNumberOfSpaces : Int = 3
    let magicPhraseWordVector : DestructuredWord
    
    var cachedResults = [String:Set<[WordIndex]>]()
    var stopWords = Set<String>()
    var smartMapping : [Character:[Int:[DestructuredWord]]]!
    
    var foundCombinations : [String] = []
    let referenceHashes = Set<String>(arrayLiteral: "e4820b45d2277f3844eac66c903e84be", "23170acc097c24edb98fc5488ab033fe", "665e5bcb0c20062fe8abaaf4628bb154")
    let wordkLookup : WordLookup
    
    var cachedOriginalWordsLookup = [[WordIndex]:Set<Set<Int>>]()
    
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
    
    func findCombinations() -> [String:String] {
        Swift.print("Testing on \(self.wordkLookup.uniqueDestructuredWords.count) unique words")
        var totalFound = 0
        
        let combinationTester = CombinationTester(referenceHashes: self.referenceHashes, wordLookup: self.wordkLookup)
        for (index,uniqueWord) in wordkLookup.uniqueDestructuredWords.enumerated() {
//            Swift.print("Testing for \(uniqueWord.wordSorting)")
            let combinations = self.identifyCombinations(accumulatedWord: uniqueWord)
            
//            Swift.print("\(combinations.count) found for \(uniqueWord.wordSorting)")
            // Producce all combinations
            for combination in combinations {

                var copy = combination
                copy.append(index)
                let combinationsOfOriginalWords = self.backtraceOriginalWords(fromWordIndices: copy.sorted())
                for combinationOfOriginalWords in combinationsOfOriginalWords {
                    let matchOfReference = combinationTester.testForValidCombinations(ofWords: combinationOfOriginalWords)
                    self.foundCombinations.append(contentsOf: matchOfReference)
                }
            }
            totalFound = totalFound + combinations.count
        }
        Swift.print("Total found: \(totalFound)")
        return testForMD5Matches(inStrings: self.foundCombinations)
        
//        return foundSolutions
    }
    
    private func testForMD5Matches(inStrings strings: [String]) -> [String:String] {
        // Write all combinations to file
        var foundSolutions : [String:String] = [:]
        // Swift.print("Writing to file for \"\(uniqueWord.wordSorting)\"")
        guard let documentsURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
           fatalError("Cannot lookup documents directory")
        }
        let fileName = documentsURL.appendingPathComponent("blah").appendingPathExtension("txt")

        self.write(strings: strings, toFile: fileName)

        let md5Mapping = self.produceMD5s(forFileInPath: fileName, strings: strings)
//        Swift.print("Produced MD5s for \"\(uniqueWord.wordSorting)\"")
        for hash in self.referenceHashes {
            if let match = md5Mapping[hash] {
                Swift.print("Sentence: '\(match)' hashes to \(hash)")
                foundSolutions[hash] = match
            }
        }
        return foundSolutions
    }
    
    private func write(strings: [String], toFile file: URL) {
        Swift.print("Starting writing to file")
        let toWrite = strings.joined(separator: "\n")
        try! toWrite.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        Swift.print("Ended writing to file")
    }
    
    private func produceMD5s(forFileInPath filePath:URL, strings: [String]) -> [String:String] {
        let commandToRun = "python3 /Users/Morten/Library/Containers/Albertsen.AnaFinder/Data/Documents/hasher.py \(filePath.relativePath)"
        let output = commandToRun.runAsCommand().components(separatedBy: CharacterSet.newlines)
        var returnDict = [String:String](minimumCapacity: strings.count)
        for (index, value) in strings.enumerated() {
            guard returnDict[output[index]] == nil else {
                fatalError("Not expected")
            }
            let toStore = output[index].trimmingCharacters(in: .symbols)
            returnDict[toStore] = value
        }
        return returnDict
    }
    
    /**
     Identifies combinations whose combined constituents matches those of magicphrase.
     In a combination the same word may appear multiple times.
     */
    func identifyCombinations(accumulatedWord: DestructuredWord, currentIndex: Int = 0, currentDepth: Int = 1) -> Set<[WordIndex]> {
        if currentDepth > self.allowedNumberOfSpaces {
            fatalError("Did not expect to go here!")
        }
        var combinationsForWord = Set<[WordIndex]>()
        let stopword = "\(currentDepth)-\(accumulatedWord.wordSorting)"
        if self.stopWords.contains(stopword) {
            return []
        }
        
        let cacheLookup = "\(currentDepth)-\(accumulatedWord.wordSorting)"
        if let cachedResult = self.cachedResults[cacheLookup] {
            /*
             We should not compute again from here - we know the resultaorstttuys already
             We _do_ need to return a result though, since accumulatedWord could have been constructed
             in multiple ways, i.e. "ta" + "pir" = "tapir", but also "tap" + "ir" -> "tapir"
            */
            var filteredCachedResult = Set<[WordIndex]>()
            for combination in cachedResult {
                let lowestElement = combination.min()!
                if combination.count + currentDepth > self.allowedNumberOfSpaces + 1 {
                    // Discard cached result: it's consists of too many words
                    continue
                }
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
                let stopword = "\(currentDepth)-\(accumulatedWord.wordSorting)"
                self.stopWords.insert(stopword)
                return []
            }
            let maximumLengthOfCandidateWord = self.magicPhrase.count -  accumulatedWord.wordSorting.count
            let startLength = currentDepth == self.allowedNumberOfSpaces ? maximumLengthOfCandidateWord : 1
            for acceptableWordLength in stride(from: startLength, to: maximumLengthOfCandidateWord+1, by: 1) {
                guard let candidatesOfAcceptableWordLength = candidatesForCharacter[acceptableWordLength] else {
                    continue
                }

                for candidateWord in candidatesOfAcceptableWordLength {
                    let indexForWord = self.wordkLookup.indexForWordSortingMapping[candidateWord.wordSorting]!
                    if indexForWord < currentIndex {
                        continue
                    }
                                       
                    let combination = accumulatedWord.combine(withWord: candidateWord)
                    if !CombinationFinder.wordCombinationIsValid(wordCombination: combination, reference: self.magicPhraseWordVector) {
                        let stopword = "\(currentDepth+1)-\(combination.wordSorting)"
                        stopWords.insert(stopword)
                        continue
                    }
                    
                    // Stop condition
                    if self.matchesReference(word: combination) {
                        // No gain of caching results here; we're at the bottom leaf anyways.
                        combinationsForWord.insert([WordIndex](arrayLiteral: indexForWord))
                        continue
                    }
                    
                    // Recurse
                    let combinations = self.identifyCombinations(accumulatedWord: combination, currentIndex: indexForWord, currentDepth: currentDepth + 1)
                    if combinations.isEmpty {
                        let stopword = "\(currentDepth+1)-\(combination.wordSorting)"
                        self.stopWords.insert(stopword)
                        continue
                    }
                    
                    for var combination in combinations {
                        combination.insert(indexForWord, at: 0)
                        combinationsForWord.insert(combination)
                    }
                    if !combinations.isEmpty {
                        let cacheLookup = "\(currentDepth+1)-\(combination.wordSorting)"
                        self.cachedResults[cacheLookup] = combinations
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
            // At bottom of recursion
            let onlyEntry = wordIndices.first!
            let wordsForIndex = self.wordkLookup.wordsSharingWordSorting[onlyEntry]
            
            var returnSet = Set<Set<Int>>()
            for wordIndex in wordsForIndex {
                returnSet.insert(Set<Int>(arrayLiteral: wordIndex))
            }
            return returnSet
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
