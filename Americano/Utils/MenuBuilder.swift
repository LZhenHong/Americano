//
//  MenuBuilder.swift
//  Americano
//
//  Created by Eden on 2023/9/24.
//

import AppKit

@resultBuilder
enum MenuBuilder {
    static func buildBlock(_ components: [NSMenuItem]...) -> [NSMenuItem] {
        components.flatMap { $0 }
    }

    static func buildExpression(_ expression: MenuItemBuilder?) -> [NSMenuItem] {
        guard let expression else {
            return []
        }
        return [expression.build()]
    }

    static func buildExpression(_ expression: NSMenuItem) -> [NSMenuItem] {
        [expression]
    }
}

extension NSMenu {
    convenience init(@MenuBuilder _ builder: () -> [NSMenuItem]) {
        self.init()
        items = builder()
    }
}
