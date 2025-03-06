//
//  MenuBarItemController.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Cocoa
import Combine
import os.log

private extension String {
  static let CupOn = "cup.and.saucer.fill"
  static let CupOff = "cup.and.saucer"
}

final class MenuBarItemController {
  static let shared = MenuBarItemController()

  private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                              category: String(describing: MenuBarItemController.self))

  private var subscriptions = Set<AnyCancellable>()
  private var statusItem: NSStatusItem!

  private lazy var settingWindowController: SettingWindowController = {
    let settings: [SettingContentRepresentable] = [
      GeneralSetting(),
      IntervalSetting(),
      BatterySetting(),
      NotificationSetting(),
      AboutSetting(),
    ]
    return SettingWindowController(settings: settings)
  }()

  private var awakePublisher: AnyPublisher<Bool, Never> {
    AppState.shared.$preventSleep.eraseToAnyPublisher()
  }

  private init() {}

  func setUp() {
    statusItem = setUpStatusItem()

    subscribePublishers()
  }

  private func setUpStatusItem() -> NSStatusItem? {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    guard let btn = statusItem.button else {
      return nil
    }

    statusItem.isVisible = true
    statusItem.behavior = .terminationOnRemoval

    btn.image = NSImage(systemSymbolName: .CupOn, accessibilityDescription: "Americano")
    btn.image?.size = NSSize(width: 18, height: 18)
    btn.image?.isTemplate = true

    btn.target = self
    btn.action = #selector(onStatusBarItemHandle(_:))
    btn.sendAction(on: [.leftMouseUp, .rightMouseUp])

    return statusItem
  }

  @objc private func onStatusBarItemHandle(_ sender: NSStatusBarButton) {
    guard let event = NSApp.currentEvent else { return }

    switch event.type {
    case .leftMouseUp:
      showMenu(sender)
    case .rightMouseUp:
      CaffeinateController.shared.toggle()
    default:
      logger.debug("Do nothing.")
    }
  }

  private func showMenu(_: NSStatusBarButton) {
    let menu = setUpMenu()
    // guard let event = NSApp.currentEvent else {
    //    return
    // }
    // This method doesn't show menu at right place.
    // NSMenu.popUpContextMenu(menu, with: event, for: sender)

    // This method was deprecated in macOS 10.14.
    // statusItem.popUpMenu(menu)

    // Make app active.
    // if #available(macOS 14.0, *) {
    //    NSApp.activate()
    // } else {
    //    NSApp.activate(ignoringOtherApps: true)
    // }
    // workaround: https://stackoverflow.com/a/57612963/5350993
    showMenu(menu, for: statusItem)
  }

  private func showMenu(_ menu: NSMenu, for item: NSStatusItem) {
    item.menu = menu
    /// tricks
    item.button?.performClick(nil)
    item.menu = nil
  }

  private func setUpMenu() -> NSMenu {
    let menu = createMenu()
    // https://github.com/onmyway133/blog/issues/428
    menu.autoenablesItems = false
    return menu
  }

  private func createMenu() -> NSMenu {
    NSMenu {
      let shared = AppState.shared
      MenuItemBuilder()
        .title(String(localized: "Prevention Durations"))
        .onEnable(awakePublisher.map(!).eraseToAnyPublisher())
        .submenu(SubMenuBuilder.build(with: shared.awakeDurations.intervals))
        .onSelect {}
      MenuItemBuilder()
        .title(String(localized: "Deactivate Prevention"))
        .onEnable(awakePublisher)
        .onSelect {
          CaffeinateController.shared.stop()
        }
      NSMenuItem.separator()
      MenuItemBuilder()
        .title(String(localized: "Settings"))
        .shortcuts(",")
        .onSelect {
          self.settingWindowController.show()
        }
      NSMenuItem.separator()
      MenuItemBuilder()
        .title(String(localized: "Quit"))
        .onSelect {
          CaffeinateController.shared.stop()
          NSApp.terminate(self)
        }
    }
  }

  private func subscribePublishers() {
    awakePublisher
      .receive(on: DispatchQueue.main)
      .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
      .map { $0 ? String.CupOn : String.CupOff }
    #if DEBUG
      .print("Status Bar Item")
    #endif
      .sink { [weak self] in
        guard let self = self else { return }
        self.changeMenuBarItemImage(with: $0)
      }
      .store(in: &subscriptions)
  }

  private func changeMenuBarItemImage(with name: String) {
    guard let btn = statusItem?.button else { return }

    btn.image = NSImage(systemSymbolName: name, accessibilityDescription: "Americano")
  }

  private func changeMenuBarItemToolTip(with tip: String) {
    guard let btn = statusItem?.button else { return }

    btn.toolTip = tip
  }
}
