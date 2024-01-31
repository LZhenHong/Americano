//
//  BatterySetting.swift
//  Americano
//
//  Created by Eden on 2024/1/9.
//

import SwiftUI

struct BatterySetting: SettingContentRepresentable {
    private var tabImageName: String {
        AppDelegate.batteryMonitor.isCharging ?
            "battery.100percent.bolt" :
            currentCapacityImageName
    }

    private var currentCapacityImageName: String {
        switch AppDelegate.batteryMonitor.currentCapacity {
        case 0..<10:
            return "battery.0percent"
        case 10..<25:
            return "battery.25percent"
        case 25..<50:
            return "battery.50percent"
        case 50..<75:
            return "battery.75percent"
        case 75 ... 100:
            return "battery.100percent"
        default:
            return "battery.50percent"
        }
    }

    var tabViewImage: NSImage? {
        NSImage(systemSymbolName: tabImageName, accessibilityDescription: nil)
    }

    var preferredTitle: String {
        String(localized: "Battery")
    }

    var isEnabled: Bool {
        AppDelegate.batteryMonitor.hasBattery
    }

    var view: AnyView {
        BatterySettingView(state: .shared)
            .frame(width: 400)
            .eraseToAnyView()
    }
}

struct BatterySettingView: View {
    @StateObject var state: AppState

    var body: some View {
        Form {
            Toggle("Deactivate when the battery level falls below", isOn: $state.batteryMonitorEnable)
            VStack(alignment: .leading) {
                BatterySlider(minValue: 10,
                              maxValue: 90,
                              currentValue: $state.batteryLowThreshold,
                              enabled: $state.batteryMonitorEnable)
                Text("If manually initiate sleep prevention on your Mac, the setting has no impact.")
                    // https://stackoverflow.com/a/59277022/5350993
                    .fixedSize(horizontal: false, vertical: true)
                    .settingPropmt()
            }
            .padding(.horizontal)
            Divider()
            Toggle("Deactivate when Mac in Low Power Mode", isOn: $state.lowPowerMonitorEnable)
            Text("Automatically deactivate when Mac's Low Power Mode is activated.")
                .settingPropmt()
            Divider()
            Toggle("Activate when Mac is charging", isOn: $state.activatePlug)
            Text("Automatically activate when your Mac is connected to the charger.")
                .settingPropmt()
            Toggle("Deactivate when Mac is not charging", isOn: $state.deactivateUnplug)
            Text("Automatically deactivate when your Mac is not connected to the charger.")
                .settingPropmt()
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    BatterySettingView(state: .sample)
        .frame(width: 400)
}
#endif
