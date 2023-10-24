//
//  ViewUtils.swift
//  Americano
//
//  Created by Eden on 2023/10/20.
//

import SwiftUI

extension NSView {
    // Borrow from:
    // https://github.com/sindresorhus/Settings/blob/a2f163d65b5c2acbe5cd644d4ac7e9c0b1f546f7/Sources/Settings/Utilities.swift#L7
    @discardableResult
    func constrainToSuperviewBounds() -> [NSLayoutConstraint] {
        guard let superview else {
            preconditionFailure("superview has to be set first")
        }

        var result = [NSLayoutConstraint]()
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|",
                                                                 options: .directionLeadingToTrailing,
                                                                 metrics: nil,
                                                                 views: ["subview": self]))
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|",
                                                                 options: .directionLeadingToTrailing,
                                                                 metrics: nil,
                                                                 views: ["subview": self]))
        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(result)

        return result
    }
}

extension View {
    func settingPropmt() -> some View {
        font(.system(size: 11))
            .foregroundColor(.secondary)
    }

    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
