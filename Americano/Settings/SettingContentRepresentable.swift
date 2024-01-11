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
    var isEnabled: Bool { get }
    @ViewBuilder var view: AnyView { get }
}

extension SettingContentRepresentable {
    var tabViewItem: NSTabViewItem {
        let viewController = SettingViewController(representable: self)
        let item = NSTabViewItem(viewController: viewController)
        item.image = tabViewImage
        item.label = preferredTitle
        return item
    }

    var isEnabled: Bool {
        true
    }
}

extension SettingContentRepresentable {
    var view: AnyView {
        HStack {
            Text(preferredTitle)
                .background(Color.red)
        }
        .frame(width: 400, height: 400)
        .eraseToAnyView()
    }
}
