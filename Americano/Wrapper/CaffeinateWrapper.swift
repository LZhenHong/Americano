//
//  CaffeinateWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Foundation
import os.log

let ONE_MINUTE_IN_SECONDS = 60

/// Delegate protocol for receiving caffeinate process lifecycle events.
protocol CaffeinateDelegate: AnyObject {
  /// Called when the caffeinate process starts successfully.
  /// - Parameters:
  ///   - caffeinate: The wrapper instance that started.
  ///   - interval: The duration for which sleep prevention will be active.
  func caffeinateDidStart(_ caffeinate: CaffeinateWrapper, interval: TimeInterval)

  /// Called when the caffeinate process terminates (either manually or due to error).
  /// - Parameter caffeinate: The wrapper instance that terminated.
  func caffeinateDidTerminate(_ caffeinate: CaffeinateWrapper)

  /// Called when the caffeinate process terminates automatically after its timer expires.
  /// - Parameter caffeinate: The wrapper instance that auto-terminated.
  func caffeinateAutoTerminate(_ caffeinate: CaffeinateWrapper)
}

// caffeinate Man Page: https://ss64.com/osx/caffeinate.html
/// Wrapper for the system `/usr/bin/caffeinate` command.
///
/// Manages the lifecycle of a caffeinate subprocess to prevent Mac from sleeping.
/// Supports timed activation, display sleep options, and delegate callbacks for state changes.
final class CaffeinateWrapper: BinWrapper {
  /// Delegate to receive process lifecycle events.
  weak var delegate: CaffeinateDelegate?

  private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                              category: String(describing: CaffeinateWrapper.self))

  private var caffeinate: Process?

  /// The underlying caffeinate process, if running.
  var process: Process? {
    caffeinate
  }

  /// Path to the caffeinate executable.
  var binPath: String {
    "/usr/bin/caffeinate"
  }

  /// Starts the caffeinate process to prevent system sleep.
  /// - Parameters:
  ///   - interval: Duration in seconds. Use `.infinity` for indefinite prevention.
  ///   - allowDisplaySleep: If `true`, allows display to sleep while preventing system sleep.
  ///   - force: If `true`, terminates any existing process and starts a new one.
  /// - Returns: `true` if the process started successfully.
  @discardableResult
  func start(
    interval: TimeInterval = .infinity,
    allowDisplaySleep: Bool = false,
    force: Bool = false
  ) -> Bool {
    if caffeinate != nil && !force {
      if running {
        // There was already a process running.
        return false
      }
      // Process exists but not running, clean it up
      stopCurrent()
    }
    return start(interval: interval, allowDisplaySleep: allowDisplaySleep)
  }

  private func stopCurrent() {
    guard let caffeinate else { return }

    caffeinate.terminate()
    caffeinate.waitUntilExit()
    caffeinate.terminationHandler = nil
    self.caffeinate = nil
  }

  private func start(interval: TimeInterval, allowDisplaySleep: Bool = false) -> Bool {
    caffeinate = newProcess()
    guard interval > 0, let caffeinate else {
      return false
    }

    let pid = ProcessInfo.processInfo.processIdentifier
    var args = allowDisplaySleep ? ["-i"] : ["-di"]
    args += ["-w", "\(pid)"]
    if interval.isFinite {
      args += ["-t", "\(interval)"]
    }
    caffeinate.arguments = args

    do {
      try caffeinate.run()

      delegate?.caffeinateDidStart(self, interval: interval)
      AppState.shared.preventSleep = true

      if interval.isFinite {
        observeCaffeinateProcessExit()
      }
      return true
    } catch {
      logger.warning("Start caffeinate process fail: \(error)")
    }
    return false
  }

  private func observeCaffeinateProcessExit() {
    guard let caffeinate else { return }

    caffeinate.terminationHandler = { [weak self] _ in
      guard let self else { return }

      DispatchQueue.main.async {
        self.stop()
        self.delegate?.caffeinateAutoTerminate(self)
      }
    }
  }

  /// Stops the caffeinate process and notifies the delegate.
  func stop() {
    guard caffeinate != nil else { return }

    stopCurrent()

    delegate?.caffeinateDidTerminate(self)
    AppState.shared.preventSleep = false
  }

  deinit {
    stop()
  }
}
