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
    private var constrains: [NSLayoutConstraint] = []

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

        let hostingViewController = NSHostingController(rootView: representable.view)
        addChild(hostingViewController)
        view.addSubview(hostingViewController.view)
        constrains = hostingViewController.view.constrainToSuperviewBounds()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        preferredContentSize = view.fittingSize
    }
}
