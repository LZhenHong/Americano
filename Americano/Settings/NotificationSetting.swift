//
//  NotificationSetting.swift
//  Americano
//
//  Created by Eden on 2024/2/25.
//

import SettingsKit
import SwiftUI

struct NotificationSetting: SettingsPane {
  var tabViewImage: NSImage? {
    NSImage(systemSymbolName: "bell.badge", accessibilityDescription: nil)
  }

  var preferredTitle: String {
    String(localized: "Notification")
  }

  var view: some View {
    NotificationSettingView(state: .shared)
      .frame(width: 400)
  }
}

struct NotificationSettingView: View {
  @ObservedObject var state: AppState

  @State private var loading = true
  @State private var status: UserNotifications.Status = .undetermined

  var requestPermissionView: some View {
    VStack(alignment: .leading) {
      Text("Undetermined.")
      Button("Request permission") {
        Task {
          try await UserNotifications.requestNotificationAuthorization()
          status = await UserNotifications.requestAuthorizationStatus()
        }
      }
    }
  }

  var denyPermissionView: some View {
    VStack(alignment: .leading) {
      Text("Denied.")
        .foregroundColor(.red)
        .bold()
      Button("Open notification settings") {
        Task {
          try await UserNotifications.openSystemNotificationSetting()
        }
      }
    }
  }

  var grantPermissionView: some View {
    Text("Granted.")
      .foregroundColor(.green)
      .bold()
  }

  var body: some View {
    Form {
      HStack(alignment: .top) {
        Text("Notification permission status:")
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
      HStack(alignment: .top) {
        Text("Notify when:")
        VStack(alignment: .leading) {
          Toggle("activate prevention", isOn: $state.notifyWhenActivate)
          Toggle("deactivate prevention", isOn: $state.notifyWhenDeactivate)
        }
      }
    }
    .task {
      loading = true
      status = await UserNotifications.requestAuthorizationStatus()
      loading = false
    }
    .padding()
  }
}
