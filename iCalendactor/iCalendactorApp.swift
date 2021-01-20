//
//  iCalendactorApp.swift
//  iCalendactor
//
//  Created by Ryan Varick on 12/27/20.
//

import SwiftUI

@main
struct iCalendactorApp: App {

    // necessary to render as a status bar item
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
 
    let contentView = ContentView()
    var popover = NSPopover.init()
    var statusBarItem = NSStatusItem()

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
//            button.image = NSImage(named: "Icon")
            button.title = "iCalendactor"
            button.action = #selector(togglePopover(_:))
        }
        
        // hide dock icon
        NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown { // close
            popover.performClose(sender)
        }
        else { // open
            if let button = statusBarItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

}
