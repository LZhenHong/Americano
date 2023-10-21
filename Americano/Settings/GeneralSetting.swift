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
        GeneralSettingView()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .eraseToAnyView()
    }
}

struct GeneralSettingView: View {
    @State private var launchAtLogin = AppDelegate.appState.launchAtLogin

    var body: some View {
        Form {
            Toggle(isOn: $launchAtLogin) {
                Text("Launch At Login")
            }
        }
    }
}
