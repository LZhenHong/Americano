//
//  CaffeinateWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Foundation
import IOKit.pwr_mgt
import os.log

/// Delegate protocol for receiving sleep prevention lifecycle events.
protocol CaffeinateDelegate: AnyObject {
  /// Called when sleep prevention starts successfully.
  /// - Parameters:
  ///   - caffeinate: The wrapper instance that started.
  ///   - interval: The duration for which sleep prevention will be active.
  func caffeinateDidStart(_ caffeinate: CaffeinateWrapper, interval: TimeInterval)

  /// Called when sleep prevention stops (either manually or due to error).
  /// - Parameter caffeinate: The wrapper instance that stopped.
  func caffeinateDidTerminate(_ caffeinate: CaffeinateWrapper)

  /// Called when sleep prevention stops automatically after its timer expires.
  /// - Parameter caffeinate: The wrapper instance that auto-terminated.
  func caffeinateAutoTerminate(_ caffeinate: CaffeinateWrapper)
}

/// Prevents system and display sleep using IOKit power management assertions.
///
/// Holds `IOPMAssertion` references in-process instead of spawning `/usr/bin/caffeinate`,
/// which keeps the app App Sandbox compatible (a Mac App Store requirement). Assertions
/// are tied to the app process and release automatically on termination, mirroring
/// `caffeinate -w <pid>` semantics.
final class CaffeinateWrapper {
  /// Delegate to receive lifecycle events.
  weak var delegate: CaffeinateDelegate?

  private let logger = Logger(
    subsystem: AppDelegate.bundleIdentifier,
    category: String(describing: CaffeinateWrapper.self)
  )

  /// Held assertion preventing idle system sleep (`caffeinate -i` equivalent). 0 = not held.
  private var systemSleepAssertion = IOPMAssertionID(0)
  /// Held assertion preventing idle display sleep (`caffeinate -d` equivalent). 0 = not held.
  private var displaySleepAssertion = IOPMAssertionID(0)
  /// Timer driving timed auto-termination (`caffeinate -t` equivalent).
  private var timeoutWorkItem: DispatchWorkItem?

  /// Whether sleep prevention is currently active.
  var running: Bool {
    systemSleepAssertion != IOPMAssertionID(0)
  }

  /// Starts preventing system sleep.
  /// - Parameters:
  ///   - interval: Duration in seconds. Use `.infinity` for indefinite prevention.
  ///   - allowDisplaySleep: If `true`, allows display to sleep while preventing system sleep.
  ///   - force: If `true`, releases any active assertions and starts fresh.
  /// - Returns: `true` if sleep prevention started successfully.
  @discardableResult
  func start(
    interval: TimeInterval = .infinity,
    allowDisplaySleep: Bool = false,
    force: Bool = false
  ) -> Bool {
    guard interval > 0 else { return false }

    if running {
      guard force else { return false }
      releaseAssertions()
    }

    guard createAssertion(kIOPMAssertionTypePreventUserIdleSystemSleep, id: &systemSleepAssertion) else {
      return false
    }

    if !allowDisplaySleep {
      guard createAssertion(kIOPMAssertionTypePreventUserIdleDisplaySleep, id: &displaySleepAssertion) else {
        releaseAssertions()
        return false
      }
    }

    scheduleAutoTerminate(after: interval)

    delegate?.caffeinateDidStart(self, interval: interval)
    AppState.shared.preventSleep = true
    return true
  }

  /// Stops sleep prevention and releases all assertions.
  func stop() {
    guard running else { return }

    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    releaseAssertions()

    delegate?.caffeinateDidTerminate(self)
    AppState.shared.preventSleep = false
  }

  deinit {
    stop()
  }

  private func createAssertion(_ type: String, id: inout IOPMAssertionID) -> Bool {
    let result = IOPMAssertionCreateWithName(
      type as CFString,
      IOPMAssertionLevel(kIOPMAssertionLevelOn),
      "Americano prevents sleep" as CFString,
      &id
    )
    guard result == kIOReturnSuccess else {
      logger.warning("Create power assertion \(type) fail: \(result)")
      return false
    }
    return true
  }

  private func releaseAssertions() {
    if displaySleepAssertion != IOPMAssertionID(0) {
      IOPMAssertionRelease(displaySleepAssertion)
      displaySleepAssertion = 0
    }
    if systemSleepAssertion != IOPMAssertionID(0) {
      IOPMAssertionRelease(systemSleepAssertion)
      systemSleepAssertion = 0
    }
  }

  private func scheduleAutoTerminate(after interval: TimeInterval) {
    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    guard interval.isFinite else { return }

    let item = DispatchWorkItem { [weak self] in
      guard let self else { return }
      stop()
      delegate?.caffeinateAutoTerminate(self)
    }
    timeoutWorkItem = item
    DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: item)
  }
}
