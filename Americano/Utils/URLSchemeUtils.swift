//
//  URLSchemeUtils.swift
//  Americano
//
//  Created by Eden on 2024/2/23.
//

import ApplicationServices
import Foundation
import os.log

final class URLSchemeInvoker {
  private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                              category: String(describing: URLSchemeInvoker.self))

  static let shared = URLSchemeInvoker()

  private var actionLookup: [String: ([String: String]) -> Void] = [:]

  private init() {}

  @objc fileprivate func handleEvent(_ event: NSAppleEventDescriptor?, with _: NSAppleEventDescriptor?) {
    guard let event,
          let param = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
          let url = URL(string: param),
          let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
          !comps.path.isEmpty,
          let action = actionLookup[comps.path]
    else {
      return
    }

    var params: [String: String] = [:]
    if let items = comps.queryItems {
      items.filter { $0.value != nil }
        .forEach { item in
          params[item.name] = item.value
        }
    }
    action(params)
  }

  func register(_ path: String, with action: @escaping ([String: String]) -> Void) {
    guard !actionLookup.keys.contains(path) else { return }
    actionLookup[path] = action
  }

  func unregister(_ path: String) {
    actionLookup.removeValue(forKey: path)
  }
}

enum URLSchemeUtils {
  static func register() {
    NSAppleEventManager.shared()
      .setEventHandler(URLSchemeInvoker.shared,
                       andSelector: #selector(URLSchemeInvoker.handleEvent(_:with:)),
                       forEventClass: AEEventClass(kInternetEventClass),
                       andEventID: AEEventID(kAEGetURL))
  }

  static func unregister() {
    NSAppleEventManager.shared()
      .removeEventHandler(forEventClass: AEEventClass(kInternetEventClass),
                          andEventID: AEEventID(kAEGetURL))
  }
}
