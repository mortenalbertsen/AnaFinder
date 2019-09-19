//
//  MD5Extension.swift
//  AnaFinder
//
//  Created by Morten on 29/08/2019.
//  Copyright © 2019 Morten Albertsen. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
    
    /**
     Convenience method for getiing the md5 for a string. Very costly, does not scale for thousands of invocations.
     */
    func md5() -> String {
        let commandToRun = "md5 -s \"\(self)\""
        let rawOutput = commandToRun.runAsCommand().trimmingCharacters(in: CharacterSet.newlines)
        guard let equalSignPosition = rawOutput.lastIndex(of: " ") else {
            fatalError("MD5 terminal output in unexpected format")
        }
        return String(rawOutput[equalSignPosition...]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /**
     Run the string as a process. 
     */
    func runAsCommand() -> String {
        let pipe = Pipe()
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", String(format:"%@", self)]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
            return result as String
        }
        else {
            return "--- Error running command - Unable to initialize string from file data ---"
        }
    }
}
