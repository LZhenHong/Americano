//
//  CaffeinateController.swift
//  Americano
//
//  Created by Eden on 2024/2/1.
//

import Combine
import Foundation
import os.log

final class CaffeinateController {
  static let shared = CaffeinateController()

  let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                      category: String(describing: CaffeinateController.self))
  let caffWrapper: CaffeinateWrapper

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

  func observeBatteryLowPowerModeIfNeed() {
    guard AppState.shared.lowPowerMonitorEnable else { return }

    BatteryMonitor.shared.observeOnLowPowerMode()
    BatteryMonitor.shared.state.$isLowPowerModeEnabled
      .filter(!)
      .sink { _ in
        self.stop()
      }
      .seal(in: lowPowerToken)
  }

  func stopObserveBatteryLowPowerMode() {
    BatteryMonitor.shared.observeOffLowPowerMode()
    lowPowerToken.unseal()
  }

  func observeBatteryPowerInfoIfNeed() {
    guard shouldObservePowerInfo else { return }

    BatteryMonitor.shared.observeOnBatteryState()

    observeBatteryToStartCaffeinate()
    observeBatteryToStopCaffeinate()
  }

  private func observeBatteryToStartCaffeinate() {
    BatteryMonitor.shared.state.$isCharging
      .filter { $0 && AppState.shared.activatePlug && !self.caffWrapper.running }
      .sink { _ in
        self.startIfAllowed()
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
      .filter { _ in self.caffWrapper.running }
      .receive(on: DispatchQueue.main)
      .sink { _ in
        self.stop()
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

  func stopObserveBatteryPowerInfoIfShould() {
    guard !shouldObservePowerInfo else { return }
    stopObserveBatteryPowerInfo()
  }

  func stopObserveBatteryPowerInfo() {
    BatteryMonitor.shared.observeOffBatteryState()
    batteryInfoSubscriptions.removeAll()
  }

  func toggle() {
    if caffWrapper.running {
      stop()
    } else {
      start()
    }
  }

  func startIfAllowed() {
    guard canActivate else { return }

    start()
  }

  @discardableResult
  func start() -> Bool {
    let interval = AppState.shared.awakeDurations.default.time
    return start(interval: interval)
  }

  @discardableResult
  func start(interval: TimeInterval, force: Bool = false) -> Bool {
    return caffWrapper.start(interval: interval, allowDisplaySleep: allowDisplaySleep, force: force)
  }

  func stop() {
    caffWrapper.stop()
  }
}

extension CaffeinateController: CaffeinateDelegate {
  func caffeinateDidStart(_: CaffeinateWrapper, interval: TimeInterval) {
    guard AppState.shared.notifyWhenActivate else { return }
    Task.init {
      let body = interval.isInfinite
        ? String(localized: "Sleep prevention will keep unless manually stopped.")
        : String(localized: "Sleep prevention will stop after \(interval.localizedTime).")
      try await UserNotifications.post(String(localized: "Sleep prevention activate."), body: body)
    }
  }

  func caffeinateDidTerminate(_: CaffeinateWrapper) {
    guard AppState.shared.notifyWhenDeactivate else { return }
    Task.init {
      try await UserNotifications.post(String(localized: "Sleep prevention deactivate."))
    }
  }

  func caffeinateAutoTerminate(_: CaffeinateWrapper) {
    if AppState.shared.activateScreenSaver {
      ScreenSaverWrapper.shared.run()
    }
  }
}
