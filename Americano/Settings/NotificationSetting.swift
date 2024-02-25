//
//  NotificationSetting.swift
//  Americano
//
//  Created by Eden on 2024/2/25.
//

import SwiftUI

struct NotificationSetting: SettingContentRepresentable {
    var tabViewImage: NSImage? {
        NSImage(systemSymbolName: "bell.badge", accessibilityDescription: nil)
    }

    var preferredTitle: String {
        String(localized: "Notification")
    }
}
