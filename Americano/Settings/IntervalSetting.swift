//
//  IntervalSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SwiftUI

struct IntervalSetting: SettingContentRepresentable {
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
}
