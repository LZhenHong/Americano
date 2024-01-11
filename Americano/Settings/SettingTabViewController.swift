//
//  SettingTabViewController.swift
//  Americano
//
//  Created by Eden on 2023/11/1.
//

import Cocoa

class SettingTabViewController: NSTabViewController {
    private lazy var tabViewSizes: [NSTabViewItem: NSSize] = [:]

    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, willSelect: tabViewItem)

        guard let tabViewItem,
              let size = tabViewItem.view?.frame.size
        else {
            return
        }
        tabViewSizes[tabViewItem] = size
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)

        guard let tabViewItem,
              let size = tabViewSizes[tabViewItem],
              let window = tabViewItem.view?.window
        else {
            return
        }

        window.title = tabViewItem.label
        resize(window: window, to: size)
    }

    private func resize(window: NSWindow, to size: NSSize) {
        let rect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        let frame = window.frameRect(forContentRect: rect)
        let toolbarHeight = window.frame.size.height - frame.size.height
        let origin = NSPoint(x: window.frame.origin.x, y: window.frame.origin.y + toolbarHeight)
        let windowFrame = NSRect(origin: origin, size: frame.size)
        window.setFrame(windowFrame, display: false, animate: true)
    }
}
