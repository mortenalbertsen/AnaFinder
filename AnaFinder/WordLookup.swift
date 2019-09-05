//
//  WordLookup.swift
//  AnaFinder
//
//  Created by Morten on 31/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

class WordLookup {
    
    let filteredWords : [String]
    private (set) var wordsSharingWordSorting : [Set<Int>]
    
    
    var indexForWordSortingMapping = [String:WordIndex]()
    var destucturedWordForIndexMapping = [WordIndex:DestructuredWord]()
    var uniqueDestructuredWords : [DestructuredWord]
    
    init(filteredWords : [String], magicPhraseLength: Int) {
        self.filteredWords = filteredWords.sorted { $0 < $1 }
        
        self.wordsSharingWordSorting = []
        
        var wordSortingToOriginalWordIndices = [String:Set<WordIndex>]()
        for (index,word) in filteredWords.enumerated() {
            let wordSorting = String(word.sorted())
            if wordSortingToOriginalWordIndices[wordSorting] == nil {
               wordSortingToOriginalWordIndices[wordSorting] = Set<WordIndex>()
            }
            wordSortingToOriginalWordIndices[wordSorting]!.insert(index)
        }
        let orderedWordSorting = wordSortingToOriginalWordIndices.sorted { a, b in
            return a.key < b.key
        }
        self.wordsSharingWordSorting = orderedWordSorting.map { element in
            return element.value
        }
        
        self.uniqueDestructuredWords = []
        
        for (index,entry) in orderedWordSorting.enumerated() {
            let wordSorting = entry.key

            let destructuredWord = DestructuredWord(word: wordSorting, magicPhraseLength: magicPhraseLength)
            self.indexForWordSortingMapping[wordSorting] = index
            self.destucturedWordForIndexMapping[index] = destructuredWord
            self.uniqueDestructuredWords.append(destructuredWord)
        }
        Swift.print("Unique word-sortings: \(self.uniqueDestructuredWords.count)")
    }
}
