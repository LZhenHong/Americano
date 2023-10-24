//
//  AppState.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var preventSleep = false
    @Published var launchAtLogin = LaunchAtLogin.isEnabled

    // TODO: - Try use marco.
    @AppStorage(.AutoStartPrefKey, store: .shared) var autoStart = false

    static let shared = AppState()

    fileprivate init() { }
}

#if DEBUG
extension AppState {
    static var sample = {
        let state = AppState()
        state.launchAtLogin = false
        state.autoStart = true
        return state
    }()
}
#endif

extension String {
    static let AutoStartPrefKey = "\(AppDelegate.bundleIdentifier).autostart"
}
