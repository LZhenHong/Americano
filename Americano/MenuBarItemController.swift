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

final class MenuBarItemController {
    private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                                category: "MenuBarItemController")

    private var subscriptions = Set<AnyCancellable>()
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!

    private lazy var settingWindowController: SettingWindowController = {
        let settings: [SettingContentRepresentable] = [
            GeneralSetting(),
            IntervalSetting(),
            AboutSetting()
        ]
        return SettingWindowController(settings: settings)
    }()

    private var awakePublisher: AnyPublisher<Bool, Never> {
        get {
            AppState.shared.$preventSleep.eraseToAnyPublisher()
        }
    }

    func setUp() {
        statusItem = setUpStatusItem()
        menu = setUpMenu()

        subscribePublishers()
    }

    private func setUpStatusItem() -> NSStatusItem? {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let btn = statusItem.button else {
            return nil
        }

        statusItem.isVisible = true
        statusItem.behavior = .terminationOnRemoval

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

    private func createMenu() -> NSMenu {
        NSMenu  {
            MenuItemBuilder()
                .title("Keep Awake")
                .onEnable(awakePublisher.map(!).eraseToAnyPublisher())
                .onSelect {
                    let shared = AppState.shared
                    AppDelegate.caffWrapper.start(
                        interval: shared.awakeDurations.default.time,
                        allowDisplaySleep: shared.allowDisplaySleep
                    )
                }
            NSMenuItem.separator()
            MenuItemBuilder()
                .title("Stop")
                .onEnable(awakePublisher)
                .onSelect {
                    AppDelegate.caffWrapper.stop()
                }
            NSMenuItem.separator()
            MenuItemBuilder()
                .title("Enter Screen Saver")
                .onSelect {
                    /// Stop caffeinate if needed.
                    AppDelegate.caffWrapper.stop()
                    AppDelegate.screenWrapper.run()
                }
            NSMenuItem.separator()
            MenuItemBuilder()
                .title("Launch At Login")
                .onHighlight(AppState.shared.$launchAtLogin.eraseToAnyPublisher())
                .onSelect {
                    LaunchAtLogin.toggle()
                }
            NSMenuItem.separator()
            MenuItemBuilder()
                .title("Setting")
                .shortcuts(",")
                .onSelect {
                    self.settingWindowController.show()
                }
            NSMenuItem.separator()
            MenuItemBuilder()
                .title("Quit")
                .onSelect {
                    AppDelegate.caffWrapper.stop()
                    NSApplication.shared.terminate(self)
                }
        }
    }

    private func subscribePublishers() {
        awakePublisher
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .map({ $0 ? String.CupOn : String.CupOff })
#if DEBUG
            .print("Status Bar Item")
#endif
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                self.changeMenuBarItemImage(with: $0)
            }
            .store(in: &subscriptions)
    }

    private func changeMenuBarItemImage(with name: String) {
        guard let btn = statusItem?.button else {
            return
        }
        btn.image = NSImage(systemSymbolName: name, accessibilityDescription: "Americano")
    }

    private func changeMenuBarItemToolTip(with tip: String) {
        guard let btn = statusItem?.button else {
            return
        }
        btn.toolTip = tip
    }
}
