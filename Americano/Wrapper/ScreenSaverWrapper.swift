//
//  ScreenSaverWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/21.
//

import Foundation
import os.log

final class ScreenSaverWrapper: BinWrapper {
  static let shared = ScreenSaverWrapper()

  let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                      category: String(describing: ScreenSaverWrapper.self))

  var binPath: String {
    "/usr/bin/open"
  }

  private init() {}

  @discardableResult
  func run() -> Bool {
    let screenSaver = newProcess()
    screenSaver.arguments = ["-a", "ScreenSaverEngine"]
    do {
      try screenSaver.run()
      screenSaver.waitUntilExit()
      return true
    } catch {
      logger.warning("Enter screen saver fail: \(error)")
    }
    return false
  }
}
