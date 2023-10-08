//
//  MenuItemBuilder.swift
//  Americano
//
//  Created by Eden on 2023/9/28.
//

import AppKit
import Combine

final class MenuItemBuilder {
    private let menuItem = NSMenuItem()
    private var subscriptions = Set<AnyCancellable>()

    @discardableResult
    func title(_ title: String) -> Self {
        menuItem.title = title
        return self
    }

    @discardableResult
    func onSelect(_ handler: @escaping () -> Void) -> Self {
        menuItem.target = self
        menuItem.action = #selector(execute(_:))
        menuItem.representedObject = handler
        return self
    }

    @objc private func execute(_ item: NSMenuItem) {
        guard let handler = item.representedObject as? () -> Void else {
            return
        }
        handler()
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
            .map({ $0 ? NSControl.StateValue.on : NSControl.StateValue.off })
            .assign(to: \.state, on: menuItem)
            .store(in: &subscriptions)
        return self
    }

    @discardableResult
    func tag(_ tag: Int) -> Self {
        menuItem.tag = tag
        return self
    }

    func build() -> NSMenuItem {
        return menuItem
    }
}
