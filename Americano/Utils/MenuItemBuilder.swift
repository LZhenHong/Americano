//
//  MenuItemBuilder.swift
//  Americano
//
//  Created by Eden on 2023/9/28.
//

import AppKit
import Combine

/// Handles menu item action invocation and subscription storage.
final class MenuInvoker {
  static let shared = MenuInvoker()

  /// Storage for menu item subscriptions, keyed by menu item identity.
  /// This prevents retain cycles by keeping subscriptions outside of the menu item.
  private var subscriptions: [ObjectIdentifier: Set<AnyCancellable>] = [:]

  private init() {}

  @objc func execute(_ item: NSMenuItem) {
    guard let handler = item.representedObject as? () -> Void else {
      return
    }
    handler()
  }

  /// Stores subscriptions for a menu item.
  func storeSubscriptions(_ subs: Set<AnyCancellable>, for menuItem: NSMenuItem) {
    subscriptions[ObjectIdentifier(menuItem)] = subs
  }

  /// Removes all stored subscriptions, cancelling any active Combine pipelines.
  func removeAllSubscriptions() {
    subscriptions.removeAll()
  }
}

/// Fluent builder for creating NSMenuItem instances with Combine bindings.
final class MenuItemBuilder {
  private let menuItem = NSMenuItem()
  private var subscriptions = Set<AnyCancellable>()

  @discardableResult
  func title(_ title: LocalizedStringResource) -> Self {
    self.title(String(localized: title))
  }

  @discardableResult
  func title(_ title: String) -> Self {
    menuItem.title = title
    return self
  }

  @discardableResult
  func onSelect(_ handler: @escaping () -> Void) -> Self {
    menuItem.target = MenuInvoker.shared
    menuItem.action = #selector(MenuInvoker.execute(_:))
    menuItem.representedObject = handler
    return self
  }

  @discardableResult
  func onEnable(_ publisher: AnyPublisher<Bool, Never>) -> Self {
    publisher
      .receive(on: DispatchQueue.main)
      .sink { [weak menuItem] isEnabled in
        menuItem?.isEnabled = isEnabled
      }
      .store(in: &subscriptions)
    return self
  }

  @discardableResult
  func onHighlight(_ publisher: AnyPublisher<Bool, Never>) -> Self {
    publisher
      .receive(on: DispatchQueue.main)
      .map { $0 ? NSControl.StateValue.on : NSControl.StateValue.off }
      .sink { [weak menuItem] state in
        menuItem?.state = state
      }
      .store(in: &subscriptions)
    return self
  }

  @discardableResult
  func tag(_ tag: Int) -> Self {
    menuItem.tag = tag
    return self
  }

  @discardableResult
  func shortcuts(_ sc: String) -> Self {
    menuItem.keyEquivalent = sc
    return self
  }

  @discardableResult
  func submenu(_ sm: NSMenu) -> Self {
    menuItem.submenu = sm
    return self
  }

  func build() -> NSMenuItem {
    if !subscriptions.isEmpty {
      MenuInvoker.shared.storeSubscriptions(subscriptions, for: menuItem)
    }
    return menuItem
  }
}
