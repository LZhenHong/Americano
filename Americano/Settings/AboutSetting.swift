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
    VStack(spacing: SettingsDesignTokens.sectionSpacing) {
      // App Info Card
      GroupBox {
        VStack(spacing: SettingsDesignTokens.cardItemSpacing) {
          // App Icon
          Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)

          // App Name and Version
          VStack(spacing: 4) {
            Text(Bundle.main.appName ?? "Americano")
              .font(.title2)
              .fontWeight(.bold)

            Text("Version: \(displayVersion)")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
        .frame(maxWidth: .infinity)
      } label: {
        Label("Application", systemImage: "cup.and.saucer.fill")
      }
      .groupBoxStyle(SettingsCardStyle())

      #if USE_SPARKLE
      // Update Card
      GroupBox {
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text("Software Update")
              .font(.body)
            Text("Check for the latest version")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
          Button {
            AppDelegate.updaterController.updater.checkForUpdates()
          } label: {
            Text("Check for Updates")
          }
          .disabled(!AppDelegate.updaterController.updater.canCheckForUpdates)
        }
      } label: {
        Label("Updates", systemImage: "arrow.triangle.2.circlepath")
      }
      .groupBoxStyle(SettingsCardStyle())
      #endif
    }
    .padding(SettingsDesignTokens.formPadding)
    .frame(width: SettingsDesignTokens.settingsPaneWidth)
  }
}

#Preview {
  AboutSettingView()
}
