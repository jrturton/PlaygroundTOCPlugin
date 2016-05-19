//
//  PlaygroundUpdater.swift
//  PlaygroundTOC
//
//  Created by Richard Turton on 19/05/2016.
//  Copyright © 2016 Richard Turton. All rights reserved.
//

import Foundation

func addNavigationLinks(linkText: String, toContents contents: NSURL) throws {
    
    guard let contentsText = try? String(contentsOfURL: contents) else { return }
    
    var lines = contentsText.componentsSeparatedByString("\n")
    
    if linksExist(lines) {
        lines.removeLast()
        lines.removeLast()
    }
    
    lines.append(linkText)
    lines.append("")
    
    let newContents = lines.joinWithSeparator("\n")
    
    try newContents.writeToURL(contents, atomically: true, encoding: NSUTF8StringEncoding)
}

private func linksExist(lines: [String]) -> Bool {
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
