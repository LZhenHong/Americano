//
//  OnboardingView.swift
//  Americano
//
//  Created by Eden on 2026/4/24.
//

import SwiftUI

struct OnboardingView: View {
  @ObservedObject var state: AppState
  var onDismiss: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(spacing: SettingsDesignTokens.sectionSpacing) {
          // MARK: - App Identity

          VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 80, height: 80)

            VStack(spacing: 4) {
              Text(Bundle.main.appName ?? "Americano")
                .font(.title2)
                .fontWeight(.bold)

              Text(String(localized: "Keep your Mac awake, effortlessly."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
          }
          .frame(maxWidth: .infinity)
          .padding(.top, 8)

          // MARK: - Interaction Guide

          HStack(spacing: 12) {
            interactionCard(
              icon: "hand.tap.fill",
              title: String(localized: "Left-click"),
              description: String(localized: "Open the menu to choose duration and settings.")
            )
            interactionCard(
              icon: "hand.tap",
              title: String(localized: "Right-click"),
              description: String(localized: "Quickly toggle sleep prevention.")
            )
          }
          .frame(maxWidth: .infinity)

          // MARK: - Quick Setup

          VStack(alignment: .leading, spacing: 8) {
            Toggle(
              String(localized: "Activate prevention on Launch"),
              isOn: $state.activateOnLaunch
            )
            Text(String(localized: "Immediately prevents Mac going to sleep when app launched."))
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.top, 8)

          // MARK: - Footer Hint

          Text(String(localized: "Americano lives in your menu bar."))
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
        }
        .padding(SettingsDesignTokens.formPadding)
      }

      // MARK: - Action Button

      HStack {
        Spacer()
        Button {
          state.hasSeenOnboarding = true
          onDismiss()
        } label: {
          Text(String(localized: "Get Started"))
            .frame(minWidth: 100)
        }
        .keyboardShortcut(.defaultAction)
        .controlSize(.large)
      }
      .padding(SettingsDesignTokens.formPadding)
      .background(.ultraThinMaterial)
    }
    .frame(width: 440, height: 420)
  }

  private func interactionCard(icon: String, title: String, description: String) -> some View {
    VStack(spacing: 10) {
      Image(systemName: icon)
        .font(.system(size: 28))
        .foregroundStyle(.secondary)
        .frame(height: 36)

      VStack(spacing: 4) {
        Text(title)
          .font(.system(size: 14, weight: .semibold))

        Text(description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity, minHeight: 120)
    .background(SettingsDesignTokens.cardBackgroundColor)
    .cornerRadius(SettingsDesignTokens.cardCornerRadius)
  }
}

#if DEBUG
#Preview {
  OnboardingView(state: .sample) {}
}
#endif
