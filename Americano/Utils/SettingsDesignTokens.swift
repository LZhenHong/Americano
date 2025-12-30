//
//  SettingsDesignTokens.swift
//  Americano
//
//  Created by Eden on 2024/12/30.
//

import SwiftUI

/// Time-related constants
enum TimeConstants {
  static let secondsPerMinute = 60
  static let secondsPerHour = 3600
  static let maxHours = 999
  static let maxMinutesOrSeconds = 59
}

/// Design system constants for consistent settings UI
enum SettingsDesignTokens {
  // MARK: - Spacing

  /// Standard padding for form containers
  static let formPadding: CGFloat = 20

  /// Spacing between sections/groups
  static let sectionSpacing: CGFloat = 16

  /// Spacing between toggle and its description text
  static let toggleDescriptionSpacing: CGFloat = 4

  /// Horizontal padding for content within cards
  static let cardPadding: CGFloat = 12

  /// Vertical padding for content within cards
  static let cardVerticalPadding: CGFloat = 10

  /// Spacing between items within a card
  static let cardItemSpacing: CGFloat = 12

  // MARK: - Dimensions

  /// Standard width for settings panes
  static let settingsPaneWidth: CGFloat = 400

  /// Corner radius for cards (0 = standard macOS style)
  static let cardCornerRadius: CGFloat = 8

  // MARK: - Colors

  /// Background color for grouped cards - a subtle, harmonious gray
  static var cardBackgroundColor: Color {
    Color(NSColor.separatorColor).opacity(0.3)
  }

  /// Secondary text color for descriptions
  static var descriptionColor: Color {
    Color.secondary
  }
}

// MARK: - Custom GroupBoxStyle for Settings Cards

struct SettingsCardStyle: GroupBoxStyle {
  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading, spacing: SettingsDesignTokens.cardItemSpacing) {
      configuration.label
        .font(.headline)
      configuration.content
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, SettingsDesignTokens.cardPadding)
    .padding(.vertical, SettingsDesignTokens.cardVerticalPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(SettingsDesignTokens.cardBackgroundColor)
    .cornerRadius(SettingsDesignTokens.cardCornerRadius)
  }
}

// MARK: - Reusable Setting Components

/// A card container for grouping related settings
struct SettingsCard<Content: View>: View {
  let title: LocalizedStringKey
  let icon: String
  @ViewBuilder let content: () -> Content

  init(_ title: LocalizedStringKey, icon: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.icon = icon
    self.content = content
  }

  var body: some View {
    GroupBox {
      VStack(alignment: .leading, spacing: SettingsDesignTokens.cardItemSpacing) {
        content()
      }
    } label: {
      Label(title, systemImage: icon)
    }
    .groupBoxStyle(SettingsCardStyle())
  }
}

/// A setting row with a toggle and description text
struct SettingToggleRow: View {
  let title: LocalizedStringKey
  let description: LocalizedStringKey
  @Binding var isOn: Bool
  var onChange: ((Bool) -> Void)?

  init(
    _ title: LocalizedStringKey,
    description: LocalizedStringKey,
    isOn: Binding<Bool>,
    onChange: ((Bool) -> Void)? = nil
  ) {
    self.title = title
    self.description = description
    _isOn = isOn
    self.onChange = onChange
  }

  var body: some View {
    VStack(alignment: .leading, spacing: SettingsDesignTokens.toggleDescriptionSpacing) {
      Toggle(title, isOn: $isOn)
        .onChange(of: isOn) { _, newValue in
          onChange?(newValue)
        }
      Text(description)
        .settingDescription()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
