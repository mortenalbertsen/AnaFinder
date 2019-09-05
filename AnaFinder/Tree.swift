//
//  Tree.swift
//  AnaFinder
//
//  Created by Morten on 22/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

protocol Leafy {
    associatedtype NodeType
    var leafs: [Self] { get }
}

final class Tree<T> : Leafy {
    typealias NodeType = T
    let root : T
    var leafs: [Tree<T>]
    
    init(root: T, leafs: [Tree<T>] = []) {
        self.root = root
        self.leafs = leafs
    }
    
    init(root: T) {
        self.root = root
        self.leafs = []
    }
    
    func add(leaf: Tree<T>) -> Void {
        leafs.append(leaf)
    }
    
    func produceTrailsFromTopToLeafs() -> [[T]] {
        var output = [[T]]()
        if leafs.isEmpty {
            return [[self.root]]
        }
        for leaf in self.leafs {
            for childOfLeaf in leaf.produceTrailsFromTopToLeafs() {
                var toAdd = [T]()
                toAdd.append(root)
                toAdd.append(contentsOf: childOfLeaf)
                output.append(toAdd)
            }
        }
        return output
    }

}
