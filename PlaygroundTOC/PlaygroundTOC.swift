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

        let actionMenuItem = NSMenuItem(title:"Generate Playground TOC", action:#selector(self.doMenuAction), keyEquivalent:"")
        actionMenuItem.target = self

        submenu.addItem(NSMenuItem.separatorItem())
        submenu.addItem(actionMenuItem)

        return true
    }

    func doMenuAction() {
        guard
        let workspaceWindowControllers = NSClassFromString("IDEWorkspaceWindowController")?.valueForKey("workspaceWindowControllers") as? [AnyObject]
            else {
                NSBeep()
                return
        }
        
        var workspace: AnyObject?
        
        for controller in workspaceWindowControllers {
            if let window = controller.valueForKey("window") as? NSObject {
                if window == NSApp.keyWindow {
                    workspace = controller.valueForKey("_workspace")
                }
            }
        }
        
        guard let path = workspace?.valueForKey("representingFilePath")?.valueForKey("_pathString") as? String else {
            NSBeep()
            return
        }
        
        let playgroundURL = NSURL.fileURLWithPath(path)
        
        guard playgroundURL.pathExtension == "playground" else {
            NSBeep()
            return
        }
        
        let parser = ContentsParser(playgroundURL: playgroundURL)
        guard let toc = parser.createTOC() else {
            NSBeep()
            return
        }
        
        let pb = NSPasteboard.generalPasteboard()
        pb.clearContents()
        pb.setString(toc, forType: NSPasteboardTypeString)
    }
}

