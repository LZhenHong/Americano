//
//  AppDelegate.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    static let appState = AppState()
    static let caffController = CaffeinateController()
    static let screenController = ScreenSaverController()
    static let itemController = MenuBarItemController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.itemController.setUp()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
