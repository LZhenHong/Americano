//
//  AppDelegate.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "io.lzhlovesjyq.Americano"
    }

    static let appState = AppState()
    static let caffWrapper = CaffeinateWrapper()
    static let screenWrapper = ScreenSaverWrapper()
    static let barItemController = MenuBarItemController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.barItemController.setUp()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        AppDelegate.caffWrapper.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
