//
//  GeneralSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SwiftUI

struct GeneralSetting: SettingContentRepresentable {
    var tabViewImage: NSImage? {
        NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
    }

    var preferredTitle: String {
        "General"
    }

    var view: AnyView {
        GeneralSettingView(state: AppDelegate.appState)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .eraseToAnyView()
    }
}

struct GeneralSettingView: View {
    @ObservedObject var state: AppState

    var body: some View {
        Form {
            Toggle("Launch At Login", isOn: $state.launchAtLogin)
                .onChange(of: state.launchAtLogin, perform: { _ in
                    LaunchAtLogin.toggle()
                })
        }
    }
}
