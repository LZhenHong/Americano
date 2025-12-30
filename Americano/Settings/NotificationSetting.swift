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

  private var statusColor: Color {
    switch status {
    case .undetermined: .secondary
    case .granted: .green
    case .denied: .red
    }
  }

  private var statusText: String {
    switch status {
    case .undetermined: String(localized: "Undetermined")
    case .granted: String(localized: "Granted")
    case .denied: String(localized: "Denied")
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: SettingsDesignTokens.sectionSpacing) {
      // MARK: - Permission Status Section

      GroupBox {
        VStack(alignment: .leading, spacing: SettingsDesignTokens.cardItemSpacing) {
          HStack {
            Text("Permission status:")
            Spacer()
            if loading {
              ProgressView()
                .scaleEffect(0.5)
            } else {
              HStack(spacing: 6) {
                Circle()
                  .fill(statusColor)
                  .frame(width: 8, height: 8)
                Text(statusText)
                  .fontWeight(.medium)
                  .foregroundStyle(statusColor)
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
      } label: {
        Label("Permission", systemImage: "lock.shield")
      }
      .groupBoxStyle(SettingsCardStyle())

      // MARK: - Notification Preferences Section

      GroupBox {
        VStack(alignment: .leading, spacing: SettingsDesignTokens.cardItemSpacing) {
          Toggle("Notify when activate prevention", isOn: $state.notifyWhenActivate)
          Toggle("Notify when deactivate prevention", isOn: $state.notifyWhenDeactivate)
        }
      } label: {
        Label("Notify when", systemImage: "bell")
      }
      .groupBoxStyle(SettingsCardStyle())
    }
    .padding(SettingsDesignTokens.formPadding)
    .task {
      loading = true
      status = await UserNotifications.requestAuthorizationStatus()
      loading = false
    }
  }
}
