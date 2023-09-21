//
//  MenuBarItemController.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa
import os.log

fileprivate extension String {
    static let CupOn = "cup.and.saucer.fill"
    static let CupOff = "cup.and.saucer"
}

final class MenuBarItemController {
    private let logger = Logger(subsystem: "io.lzhlovesjyq.Americano",
                                category: "MenuBarItemController")

    private let token = SubscriptionToken()
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!

    func setUp() {
        statusItem = setUpStatusItem()
        menu = setUpMenu()

        subscribeSignals()
    }

    private func setUpStatusItem() -> NSStatusItem? {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let btn = statusItem.button else {
            return nil
        }

        btn.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "Americano")
        btn.image?.size = NSSize(width: 18, height: 18)
        btn.image?.isTemplate = true

        btn.target = self
        btn.action = #selector(onStatusBarItemHandle(_:))
        btn.sendAction(on: [.leftMouseUp, .rightMouseUp])

        return statusItem
    }

    @objc private func onStatusBarItemHandle(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            return
        }

        switch (event.type) {
        case .leftMouseUp:
            showMenu(sender)
        case .rightMouseUp:
            if AppDelegate.caffController.running {
                AppDelegate.caffController.stop()
            } else {
                // Start a infinite caffeinate process.
                AppDelegate.caffController.start()
            }
        default:
            logger.debug("Do nothing.")
        }
    }

    private func showMenu(_ sender: NSStatusBarButton) {
        // guard let event = NSApp.currentEvent else {
        //    return
        // }
        // This method doesn't show menu at right place.
        // NSMenu.popUpContextMenu(menu, with: event, for: sender)

        // This method was deprecated in macOS 10.14.
        // statusItem.popUpMenu(menu)

        // Make app active.
        // if #available(macOS 14.0, *) {
        //    NSApp.activate()
        // } else {
        //    NSApp.activate(ignoringOtherApps: true)
        // }
        // workaround: https://stackoverflow.com/a/57612963/5350993
        showMenu(menu, for: statusItem)
    }

    private func showMenu(_ menu: NSMenu, for item: NSStatusItem) {
        item.menu = menu
        item.button?.performClick(nil)
        item.menu = nil
    }

    private func setUpMenu() -> NSMenu? {
        let menu = NSMenu()
        // https://github.com/onmyway133/blog/issues/428
        menu.autoenablesItems = false

        let items: [MenuItem] = [
            .action(title: "Five Minutes", tag: .FiveMinutesTag, selector: #selector(startFiveMinutesCaffeinate)),
            .action(title: "Infinite", tag: .InfinityTag, selector: #selector(startInfiniteCaffinate)),
            .separator,
            .action(title: "Stop", tag: .StopTag, selector: #selector(stopCaffinate)),
            .separator,
            .action(title: "Quit", tag: .QuitTag, selector: #selector(quitApp), keyEquivalent: "Q")
        ]
        items
            .map(createMenuItem(_:))
            .forEach(menu.addItem(_:))

        return menu
    }

    private func createMenuItem(_ menuItem: MenuItem) -> NSMenuItem {
        switch (menuItem) {
        case .separator:
            return NSMenuItem.separator()
        case .action(let title, let tag, let selector, let key):
            let item = NSMenuItem(title: title, action: selector, keyEquivalent: key)
            item.tag = tag
            item.target = self
            return item
        }
    }

    @objc private func startFiveMinutesCaffeinate() {
        AppDelegate.caffController.start(time: TimeInterval(5 * ONE_MINUTE_IN_SECONDS))
    }

    @objc private func startInfiniteCaffinate() {
        AppDelegate.caffController.start()
    }

    @objc private func stopCaffinate() {
        AppDelegate.caffController.stop()
    }

    @objc private func quitApp() {
        AppDelegate.caffController.stop()
        NSApplication.shared.terminate(self)
    }

    private func subscribeSignals() {
        AppDelegate.appState.$preventSleep
            .receive(on: DispatchQueue.main)
#if DEBUG
            .print()
#endif
            .sink { [weak self] preventSleep in
                guard let self = self else {
                    return
                }
                self.changeMenuBarItemImage(with: preventSleep ? .CupOn : .CupOff)

                self.menu.item(withTag: .FiveMinutesTag)?.isEnabled = !preventSleep
                self.menu.item(withTag: .InfinityTag)?.isEnabled = !preventSleep
                self.menu.item(withTag: .StopTag)?.isEnabled = preventSleep
            }
            .seal(in: token)
    }

    private func changeMenuBarItemImage(with name: String) {
        guard let btn = statusItem?.button else {
            return
        }
        btn.image = NSImage(systemSymbolName: name, accessibilityDescription: "Americano")
    }

    deinit {
        token.unseal()
    }
}

enum MenuItem {
    case separator
    case action(title: String, tag: Int, selector: Selector?, keyEquivalent: String = "")
}

extension Int {
    static let FiveMinutesTag = 1001
    static let InfinityTag = 1002
    static let StopTag = 2001
    static let QuitTag = 3001
}
