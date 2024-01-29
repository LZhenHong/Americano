//
//  AppState.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import SwiftUI
import Storage

@storage
final class AppState: ObservableObject {
    @nonstorage 
    @Published var preventSleep = false
    @nonstorage
    @Published var launchAtLogin = LaunchAtLogin.isEnabled

    var activateOnLaunch = false
    var activateScreenSaver = false
    var allowDisplaySleep = false

    var awakeDurations = AwakeDurations()

    static let shared = AppState()

    fileprivate init() {}
}

#if DEBUG
extension AppState {
    static var sample: AppState {
        .shared
    }
}
#endif
