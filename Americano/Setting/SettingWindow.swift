//
//  SettingWindow.swift
//  Americano
//
//  Created by Eden on 2023/10/17.
//

import Cocoa

final class SettingWindow: NSWindow {
    static let shared = SettingWindow()

    private let tabViewController: NSTabViewController

    private init() {
        tabViewController = NSTabViewController()
        tabViewController.tabStyle = .toolbar
        tabViewController.title = "Setting"

        super.init(contentViewController: tabViewController)
    }
}
