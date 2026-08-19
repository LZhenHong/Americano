//
//  SettingsMigration.swift
//  Americano
//
//  Created by Eden on 2026/8/19.
//

import Foundation
import os.log

/// One-time migration of persisted settings from the legacy shared
/// `io.lzhlovesjyq.userdefaults` suite to the app's standard defaults domain.
///
/// The legacy suite is unreadable inside the App Sandbox (Mac App Store), so
/// settings now live in the standard domain. The legacy suite is shared with
/// other apps, so it is left untouched — only the keys Americano owns are copied.
enum SettingsMigration {
  private static let logger = Logger(
    subsystem: AppDelegate.bundleIdentifier,
    category: String(describing: SettingsMigration.self)
  )

  private static let legacySuiteName = "io.lzhlovesjyq.userdefaults"
  private static let keyPrefix = "io.lzhlovesjyq.appstate."
  private static let migratedFlag = "\(keyPrefix)migratedToStandardDomain"

  /// Keys Americano persists via `@storage` (the macro lowercases property names).
  private static let persistedKeys = [
    "activateonlaunch",
    "activatescreensaver",
    "allowdisplaysleep",
    "awakedurations",
    "batterymonitorenable",
    "batterylowthreshold",
    "lowpowermonitorenable",
    "activateplug",
    "deactivateunplug",
    "notifywhenactivate",
    "notifywhendeactivate",
    "hasseenonboarding",
  ]

  /// Copies legacy suite values into the standard domain. The done flag is set
  /// only after at least one value was actually copied, so an early run that
  /// cannot read the legacy suite (e.g. a sandboxed MAS build) stays eligible
  /// to migrate on a later launch of a non-sandboxed build.
  static func migrateIfNeeded() {
    let standard = UserDefaults.standard
    guard !standard.bool(forKey: migratedFlag) else { return }

    guard let legacy = UserDefaults(suiteName: legacySuiteName) else { return }

    var migrated: [String] = []
    for key in persistedKeys {
      let fullKey = keyPrefix + key
      guard standard.object(forKey: fullKey) == nil,
            let value = legacy.object(forKey: fullKey) else { continue }
      standard.set(value, forKey: fullKey)
      migrated.append(key)
    }

    if !migrated.isEmpty {
      standard.set(true, forKey: migratedFlag)
      logger.info("Migrated settings from legacy suite: \(migrated.joined(separator: ", "))")
    }
  }
}
