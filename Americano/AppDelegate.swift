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

    static let screenWrapper = ScreenSaverWrapper()
    static let barItemController = MenuBarItemController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Self.barItemController.setUp()
        CaffeinateController.shared.setUp()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        CaffeinateController.shared.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
