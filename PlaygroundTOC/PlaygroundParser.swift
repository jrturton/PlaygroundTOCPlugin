//
//  PlaygroundParser.swift
//  PlaygroundTOC
//
//  Created by Richard Turton on 16/05/2016.
//  Copyright © 2016 Richard Turton. All rights reserved.
//

import Foundation

class ContentsParser: NSObject {
    
    let playgroundURL: NSURL
    private var parser: NSXMLParser!
    
    private var pageNames = [String]()
    private let pageElementName = "page"
    private let pageNameAttribute = "name"
    
    init(playgroundURL: NSURL) {
        self.playgroundURL = playgroundURL
    }
    
    var contentsURL: NSURL {
        return playgroundURL.URLByAppendingPathComponent("contents.xcplayground", isDirectory: false)
    }
    
    private func pageURLFromPageName(pageName: String) -> NSURL {
        return playgroundURL.URLByAppendingPathComponent("Pages", isDirectory: true).URLByAppendingPathComponent(pageName + ".xcplaygroundPage", isDirectory: true)
    }
    
    private func pageContentURLFromPageURL(pageURL: NSURL) -> NSURL {
        return pageURL.URLByAppendingPathComponent("Contents.swift", isDirectory: false)
    }
    
    private func readPagesFromContents() -> [String]? {
        parser = NSXMLParser(contentsOfURL: contentsURL)
        parser.delegate = self
        pageNames.removeAll()
        parser.parse()
        return pageNames
    }
    
    private func pageTitle(pageURL: NSURL) -> String? {
        let page: String
        do {
            page = try String(contentsOfURL: pageURL)
        } catch {
            return nil
        }
        
        let scanner = NSScanner(string: page)
        let hashSet = NSCharacterSet(charactersInString: "#")
        scanner.scanUpToCharactersFromSet(hashSet, intoString: nil)
        scanner.scanCharactersFromSet(hashSet, intoString: nil)
        var title: NSString?
        scanner.scanUpToCharactersFromSet(NSCharacterSet.newlineCharacterSet(), intoString: &title)
        return title as? String
    }
    
    func createTOC() -> String? {
        guard let names = readPagesFromContents() else { return nil }
        let namesAndTitles: [(String,String)] = names.map {
            let pageURL = pageURLFromPageName($0)
            let pageContentURL = pageContentURLFromPageURL(pageURL)
            return ($0, pageTitle(pageContentURL) ?? $0)
        }
        
        let toc = namesAndTitles.reduce("/*:\n") {
            let link = "- [\($1.1)](\($1.0))\n"
            return $0 + link
        }
        
        return toc + "*/"
    }
}

extension ContentsParser: NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        guard elementName == pageElementName else { return }
        guard let pageName = attributeDict[pageNameAttribute] else { return }
        pageNames.append(pageName)
    }
}
