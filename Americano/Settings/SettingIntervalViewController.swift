//
//  SettingIntervalViewController.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import Cocoa

final class SettingIntervalViewController: NSViewController, SettingContentRepresentable {
    typealias ContentViewController = SettingIntervalViewController

    var tabViewImage: NSImage? {
        get {
            NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
        }
    }

    var preferredTitle: String {
        get {
            "Awake Interval"
        }
    }

    override func loadView() {
        view = NSView()
    }
}
