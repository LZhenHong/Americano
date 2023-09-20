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

class MenuBarItemController {
    private let logger = Logger(subsystem: "io.lzhlovesjyq.Americano",
                                category: "MenuBarItemController")

    private let token = SubscriptionToken()
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!

    func setUp() {
        subscribeSignals()

        statusItem = setUpStatusItem()
        menu = setUpMenu()
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
        btn.action = #selector(onStatusBarItemHandle)
        btn.sendAction(on: [.leftMouseUp, .rightMouseUp])

        return statusItem
    }

    @objc private func onStatusBarItemHandle() {
        guard let event = NSApp.currentEvent else {
            return
        }

        switch (event.type) {
        case .leftMouseUp:
            AppDelegate.appState.preventSleep = true
        case .rightMouseUp:
            AppDelegate.appState.preventSleep = false
        default:
            logger.debug("Do nothing.")
        }
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
