//
//  AppState.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Storage
import SwiftUI

/// Central state container for all app preferences and runtime state.
///
/// Uses the `@storage` macro for automatic persistence of user preferences.
/// Properties marked with `@nonstorage` are transient runtime state only.
@storage
final class AppState: ObservableObject {
  /// Whether sleep prevention is currently active. (Runtime state, not persisted)
  @nonstorage
  @Published var preventSleep = false
  /// Whether the app is configured to launch at login. (Runtime state, not persisted)
  @nonstorage
  @Published var launchAtLogin = LaunchAtLogin.isEnabled

  // MARK: - General

  /// Automatically activate sleep prevention when the app launches.
  var activateOnLaunch = false
  /// Start screen saver when caffeinate timer expires.
  var activateScreenSaver = false
  /// Allow the display to sleep while preventing system sleep.
  var allowDisplaySleep = false

  // MARK: - Durations

  /// Configurable duration presets for sleep prevention.
  var awakeDurations = AwakeDurations()

  // MARK: - Battery

  /// Enable automatic deactivation based on battery level.
  var batteryMonitorEnable = false
  /// Battery percentage threshold below which caffeinate should deactivate.
  var batteryLowThreshold = 50
  /// Deactivate caffeinate when Low Power Mode is enabled.
  var lowPowerMonitorEnable = false
  /// Automatically activate caffeinate when power is connected.
  var activatePlug = false
  /// Automatically deactivate caffeinate when power is disconnected.
  var deactivateUnplug = false

  // MARK: - Nofitication

  /// Show notification when sleep prevention is activated.
  var notifyWhenActivate = false
  /// Show notification when sleep prevention is deactivated.
  var notifyWhenDeactivate = false

  /// Shared singleton instance.
  static let shared = AppState()

  fileprivate init() {}
}

#if DEBUG
extension AppState {
  static var sample: AppState {
    .shared
  }
}
#endif
