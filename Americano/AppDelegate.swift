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

    static let caffWrapper = CaffeinateWrapper()
    static let screenWrapper = ScreenSaverWrapper()
    static let barItemController = MenuBarItemController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.barItemController.setUp()
        AppDelegate.caffWrapper.delegate = self

        /// Activate on Launch
        if AppState.shared.activateOnLaunch {
            AppDelegate.caffWrapper.start()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        AppDelegate.caffWrapper.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate: CaffeinateDelegate {
    func caffeinateAutoTerminate(_ caffeinate: CaffeinateWrapper) {
        if AppState.shared.activateScreenSaver {
            AppDelegate.screenWrapper.run()
        }
    }
}
