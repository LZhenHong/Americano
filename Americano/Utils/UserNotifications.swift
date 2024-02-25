//
//  UserNotifications.swift
//  Americano
//
//  Created by Eden on 2024/2/25.
//

import Cocoa
import Foundation
import UserNotifications

enum UserNotifications {
    enum Status {
        case granted, undetermined, denied
    }

    private static var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    @discardableResult
    static func requestNotificationAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.sound, .alert]
        return try await center.requestAuthorization(options: options)
    }

    static func requestAuthorizationStatus() async -> Status {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return .granted
        case .notDetermined:
            return .undetermined
        case .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    static func post(_ title: String, body: String = "") async throws {
        let mutableContent = UNMutableNotificationContent()
        mutableContent.title = title
        mutableContent.body = body

        guard let content = mutableContent.copy() as? UNNotificationContent else {
            return
        }

        let request = UNNotificationRequest(identifier: .notificationIdentifier,
                                            content: content,
                                            trigger: nil)
        try await center.add(request)
    }

    static func removeDeliveredNotifications(_ identifiers: [String] = []) {
        if identifiers.isEmpty {
            center.removeAllDeliveredNotifications()
        } else {
            center.removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }

    static func removePendingNotifications(_ identifiers: [String] = []) {
        if identifiers.isEmpty {
            center.removeAllPendingNotificationRequests()
        } else {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    static func openSystemNotificationSetting() async throws {
        guard let url: URL = .notificationSettings else { return }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        config.addsToRecentItems = false
        try await NSWorkspace.shared.open(url, configuration: config)
    }
}

extension String {
    static let notificationIdentifier = "io.lzhlovesjyq.notification.identifier"
    static let notificationSettingsPath = "x-apple.systempreferences:com.apple.preference.notifications"
}

extension URL {
    static let notificationSettings = URL(string: .notificationSettingsPath)
}
