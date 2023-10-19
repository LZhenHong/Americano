//
//  SettingWindow.swift
//  Americano
//
//  Created by Eden on 2023/10/17.
//

import Cocoa

protocol SettingWindowDataSource: AnyObject {
    func settingTabViewItems(_ window: SettingWindow) -> [any SettingContentRepresentable]
}

final class SettingWindow: NSWindow {
    static let shared = SettingWindow()

    weak var dataSource: SettingWindowDataSource?
    private(set) var tabViewController: NSTabViewController

    private init() {
        tabViewController = NSTabViewController()

        super.init(contentRect: .zero, styleMask: [.titled, .closable], backing: .buffered, defer: false)

        collectionBehavior = [.managed, .participatesInCycle, .fullScreenNone]
        title = "Settings"

        tabViewController.tabStyle = .toolbar
        contentViewController = tabViewController
    }

    func show() {
        let representables = dataSource?.settingTabViewItems(self) ?? []
        guard representables.count > 0 else {
            return
        }

        representables.map(\.tabViewItem)
            .forEach(tabViewController.addTabViewItem(_:))

        NSApplication.shared.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
        center()
    }
}