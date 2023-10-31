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
            Toggle("Launch at Login", isOn: $state.launchAtLogin)
                .onChange(of: state.launchAtLogin, perform: { _ in
                    LaunchAtLogin.toggle()
                })
            Text("Automatically opens the app when start your Mac.")
                .settingPropmt()
            Toggle("Activate on Launch", isOn: $state.activateOnLaunch)
            Text("Automatically prevents your Mac from going to sleep when launched.")
                .settingPropmt()
            Toggle("Activate ScreenSaver when nap", isOn: $state.activateScreenSaver)
            Text("Automatically activate ScreenSaver when prevention is over.")
                .settingPropmt()
            Toggle("Allow Display Sleep", isOn: $state.allowDisplaySleep)
            Text("Allow the display go to sleep.")
                .settingPropmt()
        }
        .padding()
    }
}

#Preview {
    GeneralSettingView(state: .sample)
}
