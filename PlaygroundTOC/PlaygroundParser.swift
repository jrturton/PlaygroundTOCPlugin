//
//  PlaygroundParser.swift
//  PlaygroundTOC
//
//  Created by Richard Turton on 16/05/2016.
//  Copyright © 2016 Richard Turton. All rights reserved.
//

import Foundation

struct Playground {
    let pages: [PlaygroundPage]
    
    var toc: String {
        let toc = pages.reduce("/*:\n") {
            let link = "- \($1.link)\n"
            return $0 + link
        }
        return toc + "*/"
    }
    
    func navigationLinksForPage(pageName: String) -> String? {
        
        guard let index = pages.indexOf({ $0.pageName == pageName }) else { return nil }
    
        var linkText = "//:"
        
        if index > 0 {
            linkText += (pages[index - 1].previousLink) + "\t"
        }
        linkText += "\(index + 1) of \(pages.count)\t"
        
        if index < pages.count - 1 {
            linkText += pages[index + 1].nextLink
        }
        
        return linkText
    }
        
}

struct PlaygroundPage {
    let title: String
    let pageName: String
    
    var escapedName: String {
        return pageName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) ?? pageName
    }
    
    var link: String {
        return "[\(title)](\(escapedName))"
    }
    
    var previousLink: String {
        return "[Previous: \(title)](\(escapedName))"
    }
    
    var nextLink: String {
        return "[Next: \(title)](\(escapedName))"
    }
}

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
    
    func parsePlayground() -> Playground? {
        
        guard let names = readPagesFromContents() else { return nil }
        let pages: [PlaygroundPage] = names.map {
            let pageURL = pageURLFromPageName($0)
            let pageContentURL = pageContentURLFromPageURL(pageURL)
            let title = pageTitle(pageContentURL) ?? $0
            return PlaygroundPage(title: title, pageName: $0)
        }
        
        return Playground(pages: pages)
    }
}

extension ContentsParser: NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        guard elementName == pageElementName else { return }
        guard let pageName = attributeDict[pageNameAttribute] else { return }
        pageNames.append(pageName)
    }
}
