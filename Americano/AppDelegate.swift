//
//  AppDelegate.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "io.lzhlovesjyq.Americano"
    }

    static let appState = AppState()
    static let caffWrapper = CaffeinateWrapper()
    static let screenWrapper = ScreenSaverWrapper()
    static let barItemController = MenuBarItemController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.barItemController.setUp()

        SettingWindow.shared.dataSource = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        AppDelegate.caffWrapper.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate: SettingWindowDataSource {
    func settingTabViewItems(_ window: SettingWindow) -> [any SettingContentRepresentable] {
        return [
            SettingGeneralViewController(),
            SettingIntervalViewController(),
            SettingAboutViewController()
        ]
    }
}
