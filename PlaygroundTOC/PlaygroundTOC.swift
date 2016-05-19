//
//  PlaygroundTOC.swift
//
//  Created by Richard Turton on 16/05/2016.
//  Copyright © 2016 Richard Turton. All rights reserved.
//

import AppKit

var sharedPlugin: PlaygroundTOC?

class PlaygroundTOC: NSObject {

    var bundle: NSBundle
    lazy var center = NSNotificationCenter.defaultCenter()

    // MARK: - Initialization

    class func pluginDidLoad(bundle: NSBundle) {
        let allowedLoaders = bundle.objectForInfoDictionaryKey("me.delisa.XcodePluginBase.AllowedLoaders") as! Array<String>
        if allowedLoaders.contains(NSBundle.mainBundle().bundleIdentifier ?? "") {
            sharedPlugin = PlaygroundTOC(bundle: bundle)
        }
    }

    init(bundle: NSBundle) {
        self.bundle = bundle

        super.init()
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp != nil && NSApp.mainMenu == nil) {
            center.addObserver(self, selector: #selector(self.applicationDidFinishLaunching), name: NSApplicationDidFinishLaunchingNotification, object: nil)
        } else {
            initializeAndLog()
        }
    }

    private func initializeAndLog() {
        let name = bundle.objectForInfoDictionaryKey("CFBundleName")
        let version = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString")
        let status = initialize() ? "loaded successfully" : "failed to load"
        NSLog("🔌 Plugin \(name) \(version) \(status)")
    }

    func applicationDidFinishLaunching() {
        center.removeObserver(self, name: NSApplicationDidFinishLaunchingNotification, object: nil)
        initializeAndLog()
    }

    // MARK: - Implementation

    func initialize() -> Bool {
        guard let mainMenu = NSApp.mainMenu else { return false }
        guard let item = mainMenu.itemWithTitle("File") else { return false }
        guard let submenu = item.submenu else { return false }

        let tocMenuItem = NSMenuItem(title:"Generate Playground TOC", action:#selector(self.createTOC), keyEquivalent:"")
        tocMenuItem.target = self

        submenu.addItem(NSMenuItem.separatorItem())
        submenu.addItem(tocMenuItem)

        let linkMenuItem = NSMenuItem(title: "Insert Previous / Next Links", action: #selector(self.generateNavigationLinks), keyEquivalent: "")
        linkMenuItem.target = self
        submenu.addItem(linkMenuItem)
        return true
    }

    func createTOC() {
        
        guard let playground = currentPlayground() else {
            NSBeep()
            return
        }
        
        let pb = NSPasteboard.generalPasteboard()
        pb.clearContents()
        pb.setString(playground.toc, forType: NSPasteboardTypeString)
    }
    
    func windowController() -> NSWindowController? {
        guard let currentWindowController = NSApp.keyWindow?.windowController else { return nil }
        guard currentWindowController.isKindOfClass(NSClassFromString("IDEWorkspaceWindowController")!) else { return nil }
        
        return currentWindowController
    }
    
    func currentPlayground() -> Playground? {
        
        guard let workspace = windowController()?.valueForKey("_workspace") else { return nil }
        
        guard let path = workspace.valueForKey("representingFilePath")?.valueForKey("_pathString") as? String else {
            return nil
        }
        
        let playgroundURL = NSURL.fileURLWithPath(path)
        
        guard playgroundURL.pathExtension == "playground" else {
            return nil
        }
        
        let parser = ContentsParser(playgroundURL: playgroundURL)
        return parser.parsePlayground()
    }
    
    func currentPageName() -> String? {
        
        guard let editor = windowController()?.valueForKeyPath("editorArea.lastActiveEditorContext.editor") else { return nil }
        
        var document: NSDocument! = nil
        
        if editor.isKindOfClass(NSClassFromString("IDESourceCodeEditor")!) {
            document = editor.valueForKey("sourceCodeDocument") as? NSDocument
        } else if editor.isKindOfClass(NSClassFromString("IDESourceCodeComparisonEditor")!) {
            document = editor.valueForKey("primaryDocument") as? NSDocument
        }
        
        guard document != nil else { return nil }
        let playgroundPageExtension = ".xcplaygroundpage"
        guard document.displayName.hasSuffix(playgroundPageExtension) else { return nil }
        return document.displayName.stringByReplacingOccurrencesOfString(playgroundPageExtension, withString: "")
        
    }
    
    func generateNavigationLinks() {
        guard
        let playground = currentPlayground()
        else {
            NSBeep()
            return
        }
        
        for page in playground.pages {
            if let linkText = playground.navigationLinksForPage(page.pageName) {
                do {
                    try addNavigationLinks(linkText, toContents: page.pageContentURL)
                } catch {
                    NSBeep()
                }
            }
        }
    }
}

