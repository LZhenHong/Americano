//
//  GeneralSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SwiftUI

struct GeneralSetting: SettingContentRepresentable {
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
}
