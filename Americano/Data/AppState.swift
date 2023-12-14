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
    @AppStorage(.ActivateOnLaunchPrefKey, store: .shared) var activateOnLaunch = false
    @AppStorage(.ActivateScreenSaverPrefKey, store: .shared) var activateScreenSaver = false
    @AppStorage(.AllowDisplaySleepPrefKey, store: .shared) var allowDisplaySleep = false

    @AppStorage(.AwakeDurationsPrefKey, store: .shared) var awakeDurations = AwakeDurations()

    static let shared = AppState()

    fileprivate init() {}
}

#if DEBUG
extension AppState {
    static var sample = {
        let state = AppState()
        state.launchAtLogin = false
        state.activateOnLaunch = true
        state.activateScreenSaver = true
        return state
    }()
}
#endif

extension String {
    static let ActivateOnLaunchPrefKey = "\(AppDelegate.bundleIdentifier).activateonlaunch"
    static let ActivateScreenSaverPrefKey = "\(AppDelegate.bundleIdentifier).activatescreensaver"
    static let AllowDisplaySleepPrefKey = "\(AppDelegate.bundleIdentifier).allowdisplaysleep"

    static let AwakeDurationsPrefKey = "\(AppDelegate.bundleIdentifier).awakedurations"
}
