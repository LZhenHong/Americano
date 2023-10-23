//
//  LaunchAtLogin.swift
//  Americano
//
//  Created by Eden on 2023/9/26.
//

import Foundation
import Combine
import ServiceManagement
import os.log

enum LaunchAtLogin {
    private static let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                                       category: "LaunchAtLogin")

    static var isEnabled: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
    }

    static func toggle() {
        do {
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            AppState.shared.launchAtLogin = isEnabled
        } catch {
            logger.error("Failed to \(isEnabled ? "unregister" : "register") launch at login: \(error)")
        }
    }
}
