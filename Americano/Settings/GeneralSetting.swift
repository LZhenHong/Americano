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
        GeneralSettingView(state: .shared)
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
            Text("Automatically opens the app when you start your Mac.")
                .settingPropmt()
            Toggle("Auto start when launch", isOn: $state.autoStart)
            Text("Auto starts preventing sleep when launched.")
                .settingPropmt()
        }
        .padding()
    }
}

#Preview {
    GeneralSettingView(state: .sample)
}
