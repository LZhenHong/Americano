//
//  ScreenSaverWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/21.
//

import AppKit
import os.log

/// Launches the system screen saver.
///
/// Uses `NSWorkspace` (LaunchServices) instead of spawning `/usr/bin/open`,
/// which keeps the app App Sandbox compatible (a Mac App Store requirement).
final class ScreenSaverWrapper {
  static let shared = ScreenSaverWrapper()

  private let logger = Logger(
    subsystem: AppDelegate.bundleIdentifier,
    category: String(describing: ScreenSaverWrapper.self)
  )

  private init() {}

  /// Starts the screen saver.
  /// - Returns: `true` if the launch request was accepted by LaunchServices.
  @discardableResult
  func run() -> Bool {
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.ScreenSaver.Engine")
      ?? fallbackScreenSaverURL()
    else {
      logger.warning("Enter screen saver fail: ScreenSaverEngine not found")
      return false
    }

    NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { [logger] _, error in
      if let error {
        logger.warning("Enter screen saver fail: \(error)")
      }
    }
    return true
  }

  private func fallbackScreenSaverURL() -> URL? {
    let url = URL(fileURLWithPath: "/System/Library/CoreServices/ScreenSaverEngine.app")
    return FileManager.default.fileExists(atPath: url.path) ? url : nil
  }
}
