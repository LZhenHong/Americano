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
      .frame(width: 400)
  }
}

struct GeneralSettingView: View {
  @ObservedObject var state: AppState

  var body: some View {
    Form {
      Toggle("Launch at Login", isOn: $state.launchAtLogin)
        .onChange(of: state.launchAtLogin) {
          LaunchAtLogin.toggle()
        }
      Text("Automatically launch the app when Mac starts.")
        .settingPropmt()
      Toggle("Activate prevention on Launch", isOn: $state.activateOnLaunch)
      Text("Immediately prevents Mac going to sleep when app launched.")
        .settingPropmt()
      Divider()
      Toggle("Enter ScreenSaver when deactivate prevention", isOn: $state.activateScreenSaver)
      Text("Immediately enter ScreenSaver when sleep prevention is over.")
        .settingPropmt()
      Toggle("Allow display sleep", isOn: $state.allowDisplaySleep)
      Text("Allow Mac's display go to sleep.")
        .settingPropmt()
    }
    .padding()
  }
}

#if DEBUG
  #Preview {
    GeneralSettingView(state: .sample)
  }
#endif
