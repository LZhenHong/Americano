//
//  BatterySetting.swift
//  Americano
//
//  Created by Eden on 2024/1/9.
//

import SwiftUI

struct BatterySetting: SettingContentRepresentable {
    var tabViewImage: NSImage? {
        NSImage(systemSymbolName: BatteryMonitor.shared.capacitySymbol, accessibilityDescription: nil)
    }

    var preferredTitle: String {
        String(localized: "Battery")
    }

    var isEnabled: Bool {
        BatteryMonitor.shared.hasBattery
    }

    var view: AnyView {
        BatterySettingView(state: .shared)
            .frame(width: 400)
            .eraseToAnyView()
    }
}

struct BatterySettingView: View {
    @StateObject var state: AppState

    private var batteryColor: Color {
        BatteryMonitor.shared.currentCapacity >= AppState.shared.batteryLowThreshold ? .blue : .red
    }

    var body: some View {
        Form {
            Toggle("Deactivate when the battery level falls below", isOn: $state.batteryMonitorEnable)
                .onChange(of: state.batteryMonitorEnable) { enable in
                    guard enable,
                          BatteryMonitor.shared.currentCapacity < AppState.shared.batteryLowThreshold
                    else {
                        return
                    }
                    stopCaffeinate()
                }

            if state.batteryMonitorEnable {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Current battery capacity: \(BatteryMonitor.shared.currentCapacity)%")
                            .font(.caption)
                        Image(systemName: BatteryMonitor.shared.capacitySymbol)
                            .foregroundColor(batteryColor)
                    }
                    .padding(.top, 3)
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
            }

            Divider()
            Toggle("Deactivate when Mac in Low Power Mode", isOn: $state.lowPowerMonitorEnable)
                .onChange(of: state.lowPowerMonitorEnable) { enable in
                    guard enable, BatteryMonitor.shared.isLowPowerModeEnabled else { return }
                    stopCaffeinate()
                }
            Text("Automatically deactivate when Mac's Low Power Mode is activated.")
                .settingPropmt()
            Divider()
            Toggle("Activate when Mac is charging", isOn: $state.activatePlug)
                .onChange(of: state.activatePlug) { activate in
                    guard activate, BatteryMonitor.shared.isCharging else { return }
                    CaffeinateController.shared.startIfAllowed()
                }
            Text("Automatically activate when your Mac is connected to the charger.")
                .settingPropmt()
            Toggle("Deactivate when Mac is not charging", isOn: $state.deactivateUnplug)
                .onChange(of: state.deactivateUnplug) { deactivate in
                    guard deactivate, !BatteryMonitor.shared.isCharging else { return }
                    stopCaffeinate()
                }
            Text("Automatically deactivate when your Mac is not connected to the charger.")
                .settingPropmt()
        }
        .padding()
    }

    private func stopCaffeinate() {
        CaffeinateController.shared.stop()
        CaffeinateController.shared.stopObserveBatteryPowerInfoIfShould()
    }
}

#if DEBUG
#Preview {
    BatterySettingView(state: .sample)
        .frame(width: 400)
}
#endif
