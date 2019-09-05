//
//  AnaFinderTests.swift
//  AnaFinderTests
//
//  Created by Morten on 08/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import XCTest
@testable import AnaFinder

class AnaFinderTests: XCTestCase {

    func testTree() {
        let tree = Tree<Character>(root: "A")
        
        let singleChild = Tree<Character>(root: "B")
        singleChild.add(leaf: Tree<Character>(root: "C"))
        singleChild.add(leaf: Tree<Character>(root: "D"))
        singleChild.add(leaf: Tree<Character>(root: "E"))
        
        tree.add(leaf: singleChild)
        
        let childLists = tree.produceTrailsFromTopToLeafs()
        let expectedLists : [[Character]] = [["A","B","C"], ["A","B","D"], ["A","B","E"]]
        XCTAssertEqual(childLists, expectedLists)
    }

}
