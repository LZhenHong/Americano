//
//  SettingAboutViewController.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import Cocoa

final class SettingAboutViewController: NSViewController, SettingContentRepresentable {
    typealias ContentViewController = SettingAboutViewController

    var tabViewImage: NSImage? {
        get {
            NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)
        }
    }

    var preferredTitle: String {
        get {
            "About"
        }
    }

    override func loadView() {
        view = NSView()
    }
}
