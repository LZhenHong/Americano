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
