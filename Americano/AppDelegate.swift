//
//  AppDelegate.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "io.lzhlovesjyq.Americano"
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        populateMainMenu()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        URLSchemeUtils.register()

        CaffeinateController.shared.setUp()
        MenuBarItemController.shared.setUp()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        CaffeinateController.shared.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {
    func populateMainMenu() {
        let mainMenu = NSMenu(title: "Main Menu")
        let fileMenuItem = mainMenu.addItem(withTitle: "File", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: String(localized: "File"))

        let closeWindowItem = NSMenuItem(title: String(localized: "Close Window"),
                                         action: #selector(NSWindow.performClose(_:)),
                                         keyEquivalent: "w")
        submenu.addItem(closeWindowItem)

        mainMenu.setSubmenu(submenu, for: fileMenuItem)

        NSApp.mainMenu = mainMenu
    }
}
