//
//  FactorialExtension.swift
//  AnaFinder
//
//  Created by Morten on 01/09/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation

extension Int {
    func factorial() -> Int {
        if self == 1 {
            return 1
        }
        return self * (self-1).factorial()
    }
}
