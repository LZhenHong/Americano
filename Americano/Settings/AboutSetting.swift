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
  @State private var onboardingWindowController: OnboardingWindowController?

  var displayVersion: String {
    "\(Bundle.main.appVersion ?? "1.0.0") (\(Bundle.main.buildVersion ?? "1"))"
  }

  var body: some View {
    VStack(spacing: SettingsDesignTokens.sectionSpacing) {
      // App Info Card
      SettingsCard("Application", icon: "cup.and.saucer.fill") {
        VStack(spacing: SettingsDesignTokens.cardItemSpacing) {
          Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)

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
      }

      // Welcome Card
      SettingsCard("Welcome", icon: "hand.wave") {
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text(String(localized: "Welcome Window"))
              .font(.body)
            Text(String(localized: "Show the onboarding welcome window again."))
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
          Button {
            AppState.shared.hasSeenOnboarding = false
            onboardingWindowController = OnboardingWindowController()
            onboardingWindowController?.showWindow(nil)
          } label: {
            Text(String(localized: "Show"))
          }
        }
      }

      #if USE_SPARKLE
      // Update Card
      SettingsCard("Updates", icon: "arrow.triangle.2.circlepath") {
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
      }
      #endif
    }
    .padding(SettingsDesignTokens.formPadding)
    .frame(width: SettingsDesignTokens.settingsPaneWidth)
  }
}

#Preview {
  AboutSettingView()
}
