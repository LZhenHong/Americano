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
            logger.debug("Right mouse up.")
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

        // This method was deprecated in macos 10.14.
        // item.popUpMenu(menu)

        // Make app active.
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
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
        // TODO: 创建菜单栏
        return menu
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
                self.changeMenuBarItemImageWith(name: preventSleep ? .CupOn : .CupOff)
            }
            .seal(in: token)
    }

    private func changeMenuBarItemImageWith(name: String) {
        guard let btn = statusItem?.button else {
            return
        }

        btn.image = NSImage(systemSymbolName: name, accessibilityDescription: "Americano")
    }

    deinit {
        token.unseal()
    }
}
