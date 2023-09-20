//
//  AppDelegate.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let itemController = MenuBarItemController()
    private let caffController = CaffeinateController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        itemController.setUp()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
