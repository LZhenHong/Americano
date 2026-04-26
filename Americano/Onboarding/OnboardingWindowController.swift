//
//  OnboardingWindowController.swift
//  Americano
//
//  Created by Eden on 2026/4/24.
//

import Cocoa
import SwiftUI

final class OnboardingWindowController: NSWindowController, NSWindowDelegate {
  private static var retainedControllers: [OnboardingWindowController] = []

  init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 440, height: 420),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: false
    )
    window.title = String(localized: "Welcome to Americano")
    window.center()
    window.isReleasedWhenClosed = false
    window.level = .modalPanel

    super.init(window: window)
    window.delegate = self
    Self.retainedControllers.append(self)

    let contentView = OnboardingView(state: .shared) { [weak self] in
      self?.close()
    }
    window.contentViewController = NSHostingController(rootView: contentView)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func windowWillClose(_: Notification) {
    AppState.shared.hasSeenOnboarding = true
    Self.retainedControllers.removeAll { $0 === self }
  }
}
