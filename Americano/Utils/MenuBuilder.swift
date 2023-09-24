//
//  MenuBuilder.swift
//  Americano
//
//  Created by Eden on 2023/9/24.
//

import AppKit

@resultBuilder
enum MenuBuilder {
    static func buildBlock(_ components: NSMenuItem...) -> NSMenu {
        let menu = NSMenu()
        components.forEach(menu.addItem(_:))
        return menu
    }
}

extension NSMenuItem {
    static func action(title: String, target: AnyObject?, selector: Selector?, tag: Int = 0, keyEquivalent: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: keyEquivalent)
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
