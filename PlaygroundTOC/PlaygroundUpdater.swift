//
//  PlaygroundUpdater.swift
//  PlaygroundTOC
//
//  Created by Richard Turton on 19/05/2016.
//  Copyright © 2016 Richard Turton. All rights reserved.
//

import Foundation

func addNavigationLinks(_ linkText: String, toContents contents: URL) throws {
    
    guard let contentsText = try? String(contentsOf: contents, encoding: .utf8) else { return }
    
    var lines = contentsText.components(separatedBy: "\n")
    
    if linksExist(lines) {
        lines.removeLast()
        lines.removeLast()
    }
    
    lines.append(linkText)
    lines.append("")
    
    let newContents = lines.joined(separator: "\n")
    
    try newContents.write(to: contents, atomically: true, encoding: String.Encoding.utf8)
}

private func linksExist(_ lines: [String]) -> Bool {
    // Assuming a MD comment line followed by an empty line is existing navigation links
    
    if lines.count < 3 {
        return false
    }
    
    if lines.last != "" {
        return false
    }
    
    if lines[lines.count - 2].hasPrefix("//:") {
        return true
    }
    
    return false
    
}
