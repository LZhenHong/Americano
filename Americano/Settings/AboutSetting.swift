//
//  AboutSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SwiftUI

struct AboutSetting: SettingContentRepresentable {
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
}
