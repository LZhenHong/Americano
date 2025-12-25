//
//  BatteryMonitor.swift
//  Americano
//
//  Created by Eden on 2024/1/9.
//

import Cocoa
import Combine
import IOKit.ps

/// Observable state object for battery information.
final class BatteryState: ObservableObject {
  /// Whether Low Power Mode is currently enabled.
  @Published var isLowPowerModeEnabled = false
  /// Whether the Mac is currently charging.
  @Published var isCharging = false
  /// Current battery capacity percentage (0-100).
  @Published var currentCapacity = 0
}

/// Monitors battery state and power source changes using IOKit.
///
/// This singleton provides real-time battery information and can observe
/// changes to charging state, capacity, and Low Power Mode.
final class BatteryMonitor {
  static let shared = BatteryMonitor()

  /// Observable battery state for SwiftUI/Combine bindings.
  private(set) var state = BatteryState()
  private let token = SubscriptionToken()

  private var loopSource: CFRunLoopSource?

  private var powerSourceInfo: [String: Any] {
    guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
          let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [[String: Any]],
          let source = sources.first
    else {
      return [:]
    }
    return source
  }

  private var isListeningPowerSourceInfo: Bool {
    loopSource != nil
  }

  /// Whether Low Power Mode is currently enabled on the system.
  var isLowPowerModeEnabled: Bool {
    ProcessInfo.processInfo.isLowPowerModeEnabled
  }

  /// Whether the device has an internal battery.
  var hasBattery: Bool {
    guard let batteryType = powerSourceInfo[kIOPSTypeKey] as? String else {
      return false
    }
    return batteryType == kIOPSInternalBatteryType
  }

  /// Whether the Mac is currently connected to power and charging.
  var isCharging: Bool {
    guard let charging = powerSourceInfo[kIOPSIsChargingKey] as? Bool else {
      return false
    }
    return charging
  }

  /// Current battery charge level as a percentage (0-100).
  var currentCapacity: Int {
    guard let capacity = powerSourceInfo[kIOPSCurrentCapacityKey] as? Int else {
      return 0
    }
    return capacity
  }

  /// SF Symbol name representing the current battery state.
  ///
  /// Returns a bolt icon when charging, otherwise a capacity-based battery icon.
  var capacitySymbol: String {
    isCharging ? "battery.100percent.bolt" : currentCapacityImageName
  }

  private var currentCapacityImageName: String {
    switch currentCapacity {
    case 0..<10:
      "battery.0percent"
    case 10..<25:
      "battery.25percent"
    case 25..<50:
      "battery.50percent"
    case 50..<75:
      "battery.75percent"
    case 75...100:
      "battery.100percent"
    default:
      "battery.50percent"
    }
  }

  private init() {
    setUpStates()
  }

  deinit {
    observeOffBatteryState()
    observeOffLowPowerMode()
  }

  private func setUpStates() {
    state.isLowPowerModeEnabled = isLowPowerModeEnabled
    state.isCharging = isCharging
    state.currentCapacity = currentCapacity
  }

  /// Starts observing battery state changes (charging and capacity).
  ///
  /// Sets up an IOKit run loop source to receive power source notifications.
  /// Updates `state.isCharging` and `state.currentCapacity` when changes occur.
  func observeOnBatteryState() {
    guard !isListeningPowerSourceInfo else { return }

    let ctx = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    loopSource = IOPSNotificationCreateRunLoopSource({ context in
      guard let ctx = context else { return }

      let monitor = Unmanaged<BatteryMonitor>.fromOpaque(ctx).takeUnretainedValue()
      monitor.state.isCharging = monitor.isCharging
      monitor.state.currentCapacity = monitor.currentCapacity
    }, ctx).takeRetainedValue()
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loopSource, .defaultMode)
  }

  /// Stops observing battery state changes.
  ///
  /// Removes the IOKit run loop source and cleans up resources.
  func observeOffBatteryState() {
    guard isListeningPowerSourceInfo, let source = loopSource else { return }

    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
    loopSource = nil
  }

  /// Starts observing Low Power Mode state changes.
  ///
  /// Subscribes to `NSProcessInfoPowerStateDidChange` notifications and updates
  /// `state.isLowPowerModeEnabled` when the system's Low Power Mode setting changes.
  func observeOnLowPowerMode() {
    guard !token.isValid else { return }

    NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
      .receive(on: DispatchQueue.main)
      .sink { _ in
        self.state.isLowPowerModeEnabled = self.isLowPowerModeEnabled
      }
      .seal(in: token)
  }

  /// Stops observing Low Power Mode state changes.
  func observeOffLowPowerMode() {
    token.unseal()
  }
}

extension BatteryMonitor: CustomStringConvertible {
  var description: String {
    """
    BatteryMonitor:
        isLowPowerModeEnabled: \(isLowPowerModeEnabled)
        hasBattery: \(hasBattery)
        isCharging: \(isCharging)
        currentCapacity: \(currentCapacity)
    """
  }
}

// https://github.com/NSHipster/nshipster.cn/blob/master/_posts/2015-04-13-unmanaged.md
