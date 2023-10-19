//
//  SettingContentRepresentable.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import Cocoa

protocol SettingContentRepresentable: AnyObject {
    associatedtype ContentViewController: NSViewController

    var tabViewImage: NSImage? { get }
    var preferredTitle: String { get }
}

extension SettingContentRepresentable {
    var tabViewItem: NSTabViewItem {
        get {
            let vc = ContentViewController()
            vc.title = preferredTitle
            let item = NSTabViewItem(viewController: vc)
            item.image = tabViewImage
            item.label = preferredTitle
            return item
        }
    }
}
