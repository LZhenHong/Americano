//
//  SettingWindowController.swift
//  Americano
//
//  Created by Eden on 2023/10/17.
//

import Cocoa

final class SettingWindowController: NSWindowController {
    private var tabViewController: SettingTabViewController
    private(set) var settings: [SettingContentRepresentable]

    init(settings: [SettingContentRepresentable]) {
        self.settings = settings

        tabViewController = SettingTabViewController()
        tabViewController.tabStyle = .toolbar

        let validSettings = settings.filter(\.isEnabled)
        if validSettings.count > 0 {
            tabViewController.tabViewItems = validSettings.map(\.tabViewItem)
        }

        let window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.collectionBehavior = [.managed, .participatesInCycle, .fullScreenNone]
        window.title = String(localized: "Settings")
        window.contentViewController = tabViewController

        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) can not been called.")
    }

    func show(_ level: NSWindow.Level = .screenSaver) {
        guard let window else { return }

        NSApp.activate(ignoringOtherApps: true)

        if !window.isKeyWindow {
            window.center()
        }
        window.level = level
        window.makeKeyAndOrderFront(NSApp)
        showWindow(self)
    }
}
