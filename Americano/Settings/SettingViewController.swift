//
//  SettingViewController.swift
//  Americano
//
//  Created by Eden on 2023/10/20.
//

import Cocoa
import SwiftUI

final class SettingViewController: NSViewController {
    private let representable: SettingContentRepresentable

    init(representable: SettingContentRepresentable) {
        self.representable = representable
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) can not been called.")
    }
    
    // https://sarunw.com/posts/how-to-initialize-nsviewcontroller-programmatically-without-nib/
    override func loadView() {
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let hostingView = NSHostingView(rootView: representable.view)
        view.addSubview(hostingView)
        hostingView.constrainToSuperviewBounds()
    }
}
