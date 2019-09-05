//
//  ViewController.swift
//  AnaFinder
//
//  Created by Morten on 08/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var destructuredWords = [DestructuredWord]()
    
    var iterators = [Character:[Int:DestructuredWord]]()
    @IBOutlet weak var inputField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func findAnagram(_ sender: Any) {
        let magicPhrase = inputField.stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let path = Bundle.main.url(forResource: "wordlist", withExtension: "txt") else {
            fatalError("Failed to obtain path for text resource")
        }
        let algorithmRunner = AlgorithmRunner(file: path, magicPhrase: magicPhrase)
        algorithmRunner.run()
    }
}
