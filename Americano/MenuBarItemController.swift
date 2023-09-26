//
//  MenuBarItemController.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa
import Combine
import os.log

fileprivate extension String {
    static let CupOn = "cup.and.saucer.fill"
    static let CupOff = "cup.and.saucer"
}

fileprivate extension Int {
    static let FiveMinutesTag = 1001
    static let InfinityTag = 1002
    static let StopTag = 2001
    static let LaunchAtLoginTag = 3001
}

final class MenuBarItemController {
    private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                                category: "MenuBarItemController")

    private var subscriptions = Set<AnyCancellable>()
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

        btn.image = NSImage(systemSymbolName: .CupOn, accessibilityDescription: "Americano")
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
            if AppDelegate.caffWrapper.running {
                AppDelegate.caffWrapper.stop()
            } else {
                // Start a infinite caffeinate process.
                AppDelegate.caffWrapper.start()
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
        /// tricks
        item.button?.performClick(nil)
        item.menu = nil
    }

    private func setUpMenu() -> NSMenu? {
        let menu = createMenu()
        // https://github.com/onmyway133/blog/issues/428
        menu.autoenablesItems = false
        return menu
    }

    @MenuBuilder
    private func createMenu() -> NSMenu {
//        NSMenuItem("Five Minutes")
//            .tag(.FiveMinutesTag)
//            .onSelect {
//                AppDelegate.caffWrapper.start(time: TimeInterval(5 * ONE_MINUTE_IN_SECONDS))
//            }
        NSMenuItem("Keep Awake")
            .tag(.InfinityTag)
            .onSelect {
                AppDelegate.caffWrapper.start()
            }
        NSMenuItem.separator()
        NSMenuItem("Stop")
            .tag(.StopTag)
            .onSelect {
                AppDelegate.caffWrapper.stop()
            }
        NSMenuItem.separator()
        NSMenuItem("Enter Screen Saver")
            .onSelect {
                /// Stop caffeinate if needed.
                AppDelegate.caffWrapper.stop()
                AppDelegate.screenWrapper.run()
            }
        NSMenuItem.separator()
        NSMenuItem("Launch At Login")
            .tag(.LaunchAtLoginTag)
            .onSelect {
                LaunchAtLogin.toggle()
            }
        NSMenuItem.separator()
        NSMenuItem("Quit")
            .onSelect {
                AppDelegate.caffWrapper.stop()
                NSApplication.shared.terminate(self)
            }
    }

    private func subscribeSignals() {
        let preventSleepSignal = AppDelegate.appState.$preventSleep.receive(on: DispatchQueue.main)
        preventSleepSignal
            .map({ $0 ? String.CupOn : String.CupOff })
#if DEBUG
            .print()
#endif
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                self.changeMenuBarItemImage(with: $0)
            }
            .store(in: &subscriptions)

        let anyPublisher = preventSleepSignal.eraseToAnyPublisher()
        bindMenuItemEnable(.StopTag, with: anyPublisher)
        let oppsitePublisher = anyPublisher.map(!).eraseToAnyPublisher()
        bindMenuItemEnable(.FiveMinutesTag, with: oppsitePublisher)
        bindMenuItemEnable(.InfinityTag, with: oppsitePublisher)

        AppDelegate.appState.$launchAtLogin
            .receive(on: DispatchQueue.main)
#if DEBUG
            .print()
#endif
            .sink { [weak self] in
                guard let self = self, let item = self.menu.item(withTag: .LaunchAtLoginTag) else {
                    return
                }
                item.state = $0 ? .on : .off
            }
            .store(in: &subscriptions)
    }

    private func changeMenuBarItemImage(with name: String) {
        guard let btn = statusItem?.button else {
            return
        }
        btn.image = NSImage(systemSymbolName: name, accessibilityDescription: "Americano")
    }

    private func bindMenuItemEnable(_ tag: Int, with signal: AnyPublisher<Bool, Never>) {
        guard let item = menu.item(withTag: tag) else {
            return
        }
        signal
            .assign(to: \.isEnabled, on: item)
            .store(in: &subscriptions)
    }
}
