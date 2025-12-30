//
//  GeneralSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SettingsKit
import SwiftUI

struct GeneralSetting: SettingsPane {
  var tabViewImage: NSImage? {
    NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
  }

  var preferredTitle: String {
    String(localized: "General")
  }

  var view: some View {
    GeneralSettingView(state: .shared)
      .frame(width: SettingsDesignTokens.settingsPaneWidth)
  }
}

struct GeneralSettingView: View {
  @ObservedObject var state: AppState

  var body: some View {
    VStack(alignment: .leading, spacing: SettingsDesignTokens.sectionSpacing) {
      // MARK: - Startup Behavior Section

      SettingsCard("Startup", icon: "power") {
        SettingToggleRow(
          "Launch at Login",
          description: "Automatically launch the app when Mac starts.",
          isOn: $state.launchAtLogin
        ) { _ in
          LaunchAtLogin.toggle()
        }

        SettingToggleRow(
          "Activate prevention on Launch",
          description: "Immediately prevents Mac going to sleep when app launched.",
          isOn: $state.activateOnLaunch
        )
      }

      // MARK: - Sleep Behavior Section

      SettingsCard("Sleep Behavior", icon: "moon.zzz") {
        SettingToggleRow(
          "Enter ScreenSaver when deactivate prevention",
          description: "Immediately enter ScreenSaver when sleep prevention is over.",
          isOn: $state.activateScreenSaver
        )

        SettingToggleRow(
          "Allow display sleep",
          description: "Allow Mac's display go to sleep.",
          isOn: $state.allowDisplaySleep
        )
      }
    }
    .padding(SettingsDesignTokens.formPadding)
  }
}

#if DEBUG
#Preview {
  GeneralSettingView(state: .sample)
}
#endif
