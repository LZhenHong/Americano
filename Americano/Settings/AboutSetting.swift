//
//  AboutSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SettingsKit
import SwiftUI
#if USE_SPARKLE
  import Sparkle
#endif

struct AboutSetting: SettingsPane {
  var tabViewImage: NSImage? {
    NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)
  }

  var preferredTitle: String {
    String(localized: "About")
  }

  var view: some View {
    AboutSettingView()
  }
}

struct AboutSettingView: View {
  var displayVersion: String {
    "\(Bundle.main.appVersion ?? "1.0.0") (\(Bundle.main.buildVersion ?? "1"))"
  }

  var body: some View {
    VStack {
      Image(nsImage: NSApp.applicationIconImage)
      Text(Bundle.main.appName ?? "Americano")
        .font(.title)
        .fontWeight(.bold)
        .padding(.top, -5)
      #if USE_SPARKLE
        Button {
          AppDelegate.updaterController.updater.checkForUpdates()
        } label: {
          Text("Check for Updates")
        }
        .disabled(!AppDelegate.updaterController.updater.canCheckForUpdates)
        .padding(.bottom, 5)
      #endif
      Text("Version: \(displayVersion)")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(.top, 10)
    .padding(.bottom, 20)
    .frame(width: 400)
  }
}

#Preview {
  AboutSettingView()
}
