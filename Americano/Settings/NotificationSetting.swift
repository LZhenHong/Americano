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
      .frame(width: SettingsDesignTokens.settingsPaneWidth)
  }
}

struct NotificationSettingView: View {
  @ObservedObject var state: AppState

  @State private var loading = true
  @State private var status: UserNotifications.Status = .undetermined

  private var statusDisplay: (color: Color, text: String) {
    switch status {
    case .undetermined: (.secondary, String(localized: "Undetermined"))
    case .granted: (.green, String(localized: "Granted"))
    case .denied: (.red, String(localized: "Denied"))
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: SettingsDesignTokens.sectionSpacing) {
      // MARK: - Permission Status Section

      SettingsCard("Permission", icon: "lock.shield") {
        HStack {
          Text("Permission status:")
          Spacer()
          if loading {
            ProgressView()
              .scaleEffect(0.5)
          } else {
            HStack(spacing: 6) {
              Circle()
                .fill(statusDisplay.color)
                .frame(width: 8, height: 8)
              Text(statusDisplay.text)
                .fontWeight(.medium)
                .foregroundStyle(statusDisplay.color)
            }
          }
        }

        if !loading {
          switch status {
          case .undetermined:
            Button("Request permission") {
              Task {
                try await UserNotifications.requestNotificationAuthorization()
                status = await UserNotifications.requestAuthorizationStatus()
              }
            }

          case .denied:
            Button("Open notification settings") {
              Task {
                try await UserNotifications.openSystemNotificationSetting()
              }
            }

          case .granted:
            EmptyView()
          }
        }
      }

      // MARK: - Notification Preferences Section

      SettingsCard("Notify when", icon: "bell") {
        Toggle("Notify when activate prevention", isOn: $state.notifyWhenActivate)
        Toggle("Notify when deactivate prevention", isOn: $state.notifyWhenDeactivate)
      }
    }
    .padding(SettingsDesignTokens.formPadding)
    .task {
      loading = true
      status = await UserNotifications.requestAuthorizationStatus()
      loading = false
    }
  }
}
