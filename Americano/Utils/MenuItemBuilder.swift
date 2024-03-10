//
//  MenuItemBuilder.swift
//  Americano
//
//  Created by Eden on 2023/9/28.
//

import AppKit
import Combine

final class MenuInvoker {
    static let shared = MenuInvoker()

    private init() {}

    @objc func execute(_ item: NSMenuItem) {
        guard let (handler, _) = item.representedObject as? (() -> Void, Set<AnyCancellable>) else {
            return
        }
        handler()
    }
}

final class MenuItemBuilder {
    private let menuItem = NSMenuItem()
    private var subscriptions = Set<AnyCancellable>()

    @discardableResult
    func title(_ title: LocalizedStringResource) -> Self {
        return self.title(String(localized: title))
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
        menuItem.representedObject = (handler, subscriptions)
        return self
    }

    @discardableResult
    func onEnable(_ publisher: AnyPublisher<Bool, Never>) -> Self {
        publisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: menuItem)
            .store(in: &subscriptions)
        return self
    }

    @discardableResult
    func onHighlight(_ publisher: AnyPublisher<Bool, Never>) -> Self {
        publisher
            .receive(on: DispatchQueue.main)
            .map { $0 ? NSControl.StateValue.on : NSControl.StateValue.off }
            .assign(to: \.state, on: menuItem)
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
        return menuItem
    }
}
