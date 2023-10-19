//
//  SettingGeneralViewController.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import Cocoa

final class SettingGeneralViewController: NSViewController, SettingContentRepresentable {
    typealias ContentViewController = SettingGeneralViewController

    var tabViewImage: NSImage? {
        get {
             NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
        }
    }

    var preferredTitle: String {
        get {
            "General"
        }
    }

    // https://sarunw.com/posts/how-to-initialize-nsviewcontroller-programmatically-without-nib/
    override func loadView() {
        view = NSView()
    }
}
