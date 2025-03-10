//
//  AppState.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Storage
import SwiftUI

@storage
final class AppState: ObservableObject {
  @nonstorage
  @Published var preventSleep = false
  @nonstorage
  @Published var launchAtLogin = LaunchAtLogin.isEnabled

  // MARK: - General

  var activateOnLaunch = false
  var activateScreenSaver = false
  var allowDisplaySleep = false

  // MARK: - Durations

  var awakeDurations = AwakeDurations()

  // MARK: - Battery

  var batteryMonitorEnable = false
  var batteryLowThreshold = 50
  var lowPowerMonitorEnable = false
  var activatePlug = false
  var deactivateUnplug = false

  // MARK: - Nofitication

  var notifyWhenActivate = false
  var notifyWhenDeactivate = false

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
