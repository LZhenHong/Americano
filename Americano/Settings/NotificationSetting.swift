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

    var view: AnyView {
        NotificationSettingView(state: .shared)
            .frame(width: 400)
            .eraseToAnyView()
    }
}

struct NotificationSettingView: View {
    @ObservedObject var state: AppState

    @State private var loading = true
    @State private var status: UserNotifications.Status = .undetermined

    var requestPermissionView: some View {
        VStack(alignment: .leading) {
            Button("Request Permission") {
                Task.init {
                    try await UserNotifications.requestNotificationAuthorization()
                    status = await UserNotifications.requestAuthorizationStatus()
                }
            }
            Text("Permission Not Granted.")
        }
    }

    var denyPermissionView: some View {
        VStack(alignment: .leading) {
            Button("Open Settings") {
                Task.init {
                    try await UserNotifications.openSystemNotificationSetting()
                }
            }
            Text("Permission Denied.")
                .foregroundColor(.red)
                .bold()
        }
    }

    var grantPermissionView: some View {
        Text("Permission Granted.")
            .foregroundColor(.green)
            .bold()
    }

    var body: some View {
        Form {
            HStack(alignment: .top) {
                Text("Notification Permission:")
                if loading {
                    ProgressView()
                        .scaleEffect(0.5)
                } else {
                    switch status {
                    case .undetermined:
                        requestPermissionView
                    case .granted:
                        grantPermissionView
                    case .denied:
                        denyPermissionView
                    }
                }
            }
            Divider()
            Toggle("Notify when activate", isOn: $state.notifyWhenActivate)
            Text("Send notification when activate caffeinate process.")
                .settingPropmt()
            Toggle("Notify when deactivate", isOn: $state.notifyWhenDeactivate)
            Text("Send notification when deactivate caffeinate process.")
                .settingPropmt()
        }
        .onAppear {
            Task.init {
                loading = true
                status = await UserNotifications.requestAuthorizationStatus()
                loading = false
            }
        }
        .padding()
    }
}
