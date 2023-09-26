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

    private static let signal = CurrentValueSubject<Bool, Never>(isEnabled)

    static var publisher: AnyPublisher<Bool, Never> {
        signal.eraseToAnyPublisher()
    }

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
            signal.send(isEnabled)
        } catch {
            logger.error("Failed to \(isEnabled ? "unregister" : "register") launch at login: \(error)")
        }
    }
}
