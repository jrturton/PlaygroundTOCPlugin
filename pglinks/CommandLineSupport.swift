//
//  CommandLineSupport.swift
//  PlaygroundTOC
//
//  Created by Richard Turton on 30/06/2016.
//  Copyright © 2016 Richard Turton. All rights reserved.
//

import Foundation

func writeToStdError(_ str: String) {
    let handle = FileHandle.standardError()
    
    if let data = str.data(using: String.Encoding.utf8) {
        handle.write(data)
    }
}

func playground(fromURL playgroundURL: URL) -> Playground? {
    
    guard playgroundURL.pathExtension == "playground" else {
        return nil
    }
    
    let parser = ContentsParser(playgroundURL: playgroundURL)
    return parser.parsePlayground()
}

func generateNavigationLinks(playground: Playground) {
    
    for page in playground.pages {
        if let linkText = playground.navigationLinksFor(pageName: page.pageName) {
            do {
                try addNavigationLinks(linkText, toContents: page.pageContentURL)
            } catch {
                writeToStdError("\(error)")
            }
        }
    }
}
