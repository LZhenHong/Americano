//
//  AppState.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Combine

final class AppState: ObservableObject {
    @Published var preventSleep = false
    @Published var launchAtLogin = LaunchAtLogin.isEnabled
}
