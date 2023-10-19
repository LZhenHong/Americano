//
//  SettingContentRepresentable.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import Cocoa
import SwiftUI

protocol SettingContentRepresentable {
    var tabViewImage: NSImage? { get }
    var preferredTitle: String { get }
}

extension SettingContentRepresentable {
    var tabViewItem: NSTabViewItem {
        get {
            let viewController = SettingViewController(representable: self)
            let item = NSTabViewItem(viewController: viewController)
            item.image = tabViewImage
            item.label = preferredTitle
            return item
        }
    }
}
