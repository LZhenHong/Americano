//
//  MenuItemExt.swift
//  Americano
//
//  Created by Eden on 2023/9/25.
//

import AppKit
import Combine

final class MenuInvoker {
    static let shared = MenuInvoker()

    private init() { }

    @objc func execute(_ item: NSMenuItem) {
        guard let handler = item.representedObject as? () -> Void else {
            return
        }
        handler()
    }
}

extension NSMenuItem {
    convenience init(_ title: String) {
        self.init()
        self.title = title
    }

    @discardableResult
    func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func onSelect(_ handler: @escaping () -> Void) -> Self {
        representedObject = handler
        target = MenuInvoker.shared
        action = #selector(MenuInvoker.execute(_:))
        return self
    }

    @discardableResult
    func onEnable(_ publisher: AnyPublisher<Bool, Never>) -> Self {
        return self
    }

    @discardableResult
    func tag(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }
}

extension NSMenuItem {
    static func action(title: String, target: AnyObject?, selector: Selector?, tag: Int = 0) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: "")
        item.tag = tag
        item.target = target
        return item
    }

    static func section(title: String) -> NSMenuItem {
        if #available(macOS 14.0, *) {
            return NSMenuItem.sectionHeader(title: title)
        } else {
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            item.isEnabled = false
            return item
        }
    }
}
