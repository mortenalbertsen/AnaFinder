//
//  AlgorithmRunner.swift
//  AnaFinder
//
//  Created by Morten on 28/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

class AlgorithmRunner {
    
    let file: URL
    let magicPhrase: String
    
    init(file: URL, magicPhrase: String) {
        self.file = file
        self.magicPhrase = magicPhrase
    }
    
    func run() {
        // Read file and filter irrelevant words out
        let filteredWords = WordLoader.load(fromFile: self.file, referenceWord: magicPhrase)
        Swift.print("Number of filtered words: \(filteredWords.count)")
        
        let wordLookup = WordLookup(filteredWords: filteredWords, magicPhraseLength: self.magicPhrase.count)

        // Kick off algoritm
        let combinationFinder = CombinationFinder(magicPhrase: magicPhrase, wordLookup: wordLookup)
        _ = combinationFinder.findCombinations()
    }
}
