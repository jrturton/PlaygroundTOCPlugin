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
    
    func navigationLinksFor(pageName: String) -> String? {
        
        guard let index = pages.index(where: { $0.pageName == pageName }) else { return nil }
    
        var linkText = "//:"
        
        if index > 0 {
            linkText += (pages[index - 1].previousLink) + "  |  "
        }
        linkText += "page \(index + 1) of \(pages.count)"
        
        if index < pages.count - 1 {
            linkText += "  |  " + pages[index + 1].nextLink
        }
        
        return linkText
    }
        
}

struct PlaygroundPage {
    let title: String
    let pageName: String
    let pageContentURL: URL
    
    var escapedName: String {
        return pageName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? pageName
    }
    
    var link: String {
        return "[\(title)](\(escapedName))"
    }
    
    var previousLink: String {
        return "[Previous](@previous)"
    }
    
    var nextLink: String {
        return "[Next: \(title)](@next)"
    }
}

class ContentsParser: NSObject {
    
    let playgroundURL: URL
    private var parser: XMLParser!
    
    private var pageNames = [String]()
    private let pageElementName = "page"
    private let pageNameAttribute = "name"
    
    init(playgroundURL: URL) {
        self.playgroundURL = playgroundURL
    }
    
    var contentsURL: URL {
        return try! playgroundURL.appendingPathComponent("contents.xcplayground", isDirectory: false)
    }
    
    private func pageURLFromPageName(_ pageName: String) -> URL {
        return try! playgroundURL.appendingPathComponent("Pages", isDirectory: true).appendingPathComponent(pageName + ".xcplaygroundPage", isDirectory: true)
    }
    
    private func pageContentURLFromPageURL(_ pageURL: URL) -> URL {
        return try! pageURL.appendingPathComponent("Contents.swift", isDirectory: false)
    }
    
    private func readPagesFromContents() -> [String]? {
        parser = XMLParser(contentsOf: contentsURL)
        parser.delegate = self
        pageNames.removeAll()
        parser.parse()
        return pageNames
    }
    
    private func pageTitle(_ pageURL: URL) -> String? {
        let page: String
        do {
            page = try String(contentsOf: pageURL, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
        
        let scanner = Scanner(string: page)
        let hashSet = CharacterSet(charactersIn: "#")
        scanner.scanUpToCharacters(from: hashSet, into: nil)
        scanner.scanCharacters(from: hashSet, into: nil)
        var title: NSString?
        scanner.scanUpToCharacters(from: CharacterSet.newlines, into: &title)
        return title as? String
    }
    
    func parsePlayground() -> Playground? {
        
        guard let names = readPagesFromContents() else { return nil }
        let pages: [PlaygroundPage] = names.map {
            let pageURL = pageURLFromPageName($0)
            let pageContentURL = pageContentURLFromPageURL(pageURL)
            let title = pageTitle(pageContentURL) ?? $0
            return PlaygroundPage(title: title, pageName: $0, pageContentURL: pageContentURL)
        }
        
        return Playground(pages: pages)
    }
}

extension ContentsParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        guard elementName == pageElementName else { return }
        guard let pageName = attributeDict[pageNameAttribute] else { return }
        pageNames.append(pageName)
    }
}
