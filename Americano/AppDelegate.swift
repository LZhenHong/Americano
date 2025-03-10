//
//  AppDelegate.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa
#if USE_SPARKLE
  import Sparkle
#endif

final class AppDelegate: NSObject, NSApplicationDelegate {
  static var bundleIdentifier: String {
    Bundle.main.bundleIdentifier ?? "io.lzhlovesjyq.Americano"
  }

  #if USE_SPARKLE
    static let updaterController = SPUStandardUpdaterController(
      startingUpdater: true,
      updaterDelegate: nil,
      userDriverDelegate: nil
    )
  #endif

  func applicationWillFinishLaunching(_: Notification) {
    populateMainMenu()
  }

  func applicationDidFinishLaunching(_: Notification) {
    URLSchemeUtils.register()

    CaffeinateController.shared.setUp()
    MenuBarItemController.shared.setUp()
  }

  func applicationWillTerminate(_: Notification) {
    CaffeinateController.shared.stop()
  }

  func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
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
