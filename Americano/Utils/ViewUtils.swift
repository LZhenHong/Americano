//
//  ViewUtils.swift
//  Americano
//
//  Created by Eden on 2023/10/20.
//

import SwiftUI

extension View {
  /// Legacy modifier for prompt/description text (kept for compatibility)
  func settingPrompt() -> some View {
    settingDescription()
  }

  /// Description text style for settings (11pt, secondary color)
  func settingDescription() -> some View {
    font(.system(size: 11))
      .foregroundStyle(.secondary)
  }
}
