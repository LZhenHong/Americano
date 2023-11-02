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
        Self.barItemController.setUp()
        Self.caffWrapper.delegate = self

        /// Activate on Launch
        if AppState.shared.activateOnLaunch {
            Self.caffWrapper.start()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        Self.caffWrapper.stop()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate: CaffeinateDelegate {
    func caffeinateAutoTerminate(_ caffeinate: CaffeinateWrapper) {
        if AppState.shared.activateScreenSaver {
            Self.screenWrapper.run()
        }
    }
}
