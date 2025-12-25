//
//  CaffeinateController.swift
//  Americano
//
//  Created by Eden on 2024/2/1.
//

import Combine
import Foundation
import os.log

/// Controls the caffeinate process to prevent Mac from sleeping.
///
/// This singleton manages the lifecycle of the system's `caffeinate` command,
/// handles battery monitoring integration, and responds to URL scheme commands.
final class CaffeinateController {
  static let shared = CaffeinateController()

  private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                              category: String(describing: CaffeinateController.self))
  private let caffWrapper: CaffeinateWrapper

  private var lowPowerToken = SubscriptionToken()
  private var batteryInfoSubscriptions = Set<AnyCancellable>()

  private var allowDisplaySleep: Bool {
    AppState.shared.allowDisplaySleep
  }

  private var canActivate: Bool {
    if AppState.shared.batteryMonitorEnable,
       BatteryMonitor.shared.currentCapacity <= AppState.shared.batteryLowThreshold
    {
      return false
    }

    if AppState.shared.lowPowerMonitorEnable,
       BatteryMonitor.shared.isLowPowerModeEnabled
    {
      return false
    }

    if AppState.shared.deactivateUnplug,
       !BatteryMonitor.shared.isCharging
    {
      return false
    }

    return true
  }

  private var shouldObservePowerInfo: Bool {
    if AppState.shared.batteryMonitorEnable,
       BatteryMonitor.shared.currentCapacity > AppState.shared.batteryLowThreshold
    {
      return true
    }

    if AppState.shared.activatePlug || AppState.shared.deactivateUnplug {
      return true
    }

    return false
  }

  private init() {
    caffWrapper = CaffeinateWrapper()
    caffWrapper.delegate = self
  }

  /// Initializes the controller and sets up URL schemes, battery monitoring, and auto-activation.
  func setUp() {
    registerURLSchemes()
    activateIfNeed()
    observeBatteryLowPowerModeIfNeed()
    observeBatteryPowerInfoIfNeed()
  }

  private func activateIfNeed() {
    guard AppState.shared.activateOnLaunch, canActivate else { return }

    startIfAllowed()
    logger.info("Activate on Launch.")
  }

  private func observeBatteryLowPowerModeIfNeed() {
    guard AppState.shared.lowPowerMonitorEnable else { return }

    BatteryMonitor.shared.observeOnLowPowerMode()
    BatteryMonitor.shared.state.$isLowPowerModeEnabled
      .filter(!)
      .sink { [weak self] _ in
        self?.stop()
      }
      .seal(in: lowPowerToken)
  }

  private func stopObserveBatteryLowPowerMode() {
    BatteryMonitor.shared.observeOffLowPowerMode()
    lowPowerToken.unseal()
  }

  private func observeBatteryPowerInfoIfNeed() {
    guard shouldObservePowerInfo else { return }

    BatteryMonitor.shared.observeOnBatteryState()

    observeBatteryToStartCaffeinate()
    observeBatteryToStopCaffeinate()
  }

  private func observeBatteryToStartCaffeinate() {
    BatteryMonitor.shared.state.$isCharging
      .filter { [weak self] in $0 && AppState.shared.activatePlug && self?.caffWrapper.running == false }
      .sink { [weak self] _ in
        self?.startIfAllowed()
      }
      .store(in: &batteryInfoSubscriptions)
  }

  private func observeBatteryToStopCaffeinate() {
    let chargeStopPulisher = BatteryMonitor.shared.state.$isCharging
      .filter { !$0 && AppState.shared.deactivateUnplug }
    let batteryCapacityPulisher = BatteryMonitor.shared.state.$currentCapacity
      .map { capacity in
        AppState.shared.batteryMonitorEnable && capacity <= AppState.shared.batteryLowThreshold
      }
      .filter { $0 }
    chargeStopPulisher.merge(with: batteryCapacityPulisher)
      .filter { [weak self] _ in self?.caffWrapper.running == true }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.stop()
      }
      .store(in: &batteryInfoSubscriptions)
  }

  private func registerURLSchemes() {
    URLSchemeInvoker.shared.register("/activate") { params in
      guard self.canActivate else { return }
      _ = params.isEmpty ? self.start() : self.start(params)
    }

    URLSchemeInvoker.shared.register("/deactivate") { _ in self.stop() }

    URLSchemeInvoker.shared.register("/toggle") { _ in
      self.caffWrapper.running ? self.stop() : self.startIfAllowed()
    }
  }

  @discardableResult
  private func start(_ params: [String: String]) -> Bool {
    let hours = params.intValue(for: "hours")
    let minutes = params.intValue(for: "minutes")
    let seconds = params.intValue(for: "seconds")
    let interval = hours * 3600 + minutes * 60 + seconds
    return start(interval: TimeInterval(interval))
  }

  /// Stops observing battery power info if no longer needed based on current settings.
  func stopObserveBatteryPowerInfoIfShould() {
    guard !shouldObservePowerInfo else { return }
    stopObserveBatteryPowerInfo()
  }

  private func stopObserveBatteryPowerInfo() {
    BatteryMonitor.shared.observeOffBatteryState()
    batteryInfoSubscriptions.removeAll()
  }

  /// Toggles sleep prevention on or off.
  func toggle() {
    if caffWrapper.running {
      stop()
    } else {
      start()
    }
  }

  /// Starts sleep prevention if battery and power conditions allow.
  func startIfAllowed() {
    guard canActivate else { return }

    start()
  }

  /// Starts sleep prevention with the default duration from settings.
  /// - Returns: `true` if caffeinate started successfully.
  @discardableResult
  func start() -> Bool {
    let interval = AppState.shared.awakeDurations.default.time
    return start(interval: interval)
  }

  /// Starts sleep prevention for a specific duration.
  /// - Parameters:
  ///   - interval: Duration in seconds. Use `.infinity` for indefinite prevention.
  ///   - force: If `true`, restarts even if already running.
  /// - Returns: `true` if caffeinate started successfully.
  @discardableResult
  func start(interval: TimeInterval, force: Bool = false) -> Bool {
    caffWrapper.start(interval: interval, allowDisplaySleep: allowDisplaySleep, force: force)
  }

  /// Stops sleep prevention and terminates the caffeinate process.
  func stop() {
    caffWrapper.stop()
  }
}

extension CaffeinateController: CaffeinateDelegate {
  func caffeinateDidStart(_: CaffeinateWrapper, interval: TimeInterval) {
    guard AppState.shared.notifyWhenActivate else { return }
    Task {
      do {
        let body = interval.isInfinite
          ? String(localized: "Sleep prevention will keep unless manually stopped.")
          : String(localized: "Sleep prevention will stop after \(interval.localizedTime).")
        try await UserNotifications.post(String(localized: "Sleep prevention activate."), body: body)
      } catch {
        logger.error("Failed to post notification: \(error)")
      }
    }
  }

  func caffeinateDidTerminate(_: CaffeinateWrapper) {
    guard AppState.shared.notifyWhenDeactivate else { return }
    Task {
      do {
        try await UserNotifications.post(String(localized: "Sleep prevention deactivate."))
      } catch {
        logger.error("Failed to post notification: \(error)")
      }
    }
  }

  func caffeinateAutoTerminate(_: CaffeinateWrapper) {
    if AppState.shared.activateScreenSaver {
      ScreenSaverWrapper.shared.run()
    }
  }
}
