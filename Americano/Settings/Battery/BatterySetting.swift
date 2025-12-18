//
//  BatterySetting.swift
//  Americano
//
//  Created by Eden on 2024/1/9.
//

import SettingsKit
import SwiftUI

struct BatterySetting: SettingsPane {
  var tabViewImage: NSImage? {
    NSImage(systemSymbolName: BatteryMonitor.shared.capacitySymbol, accessibilityDescription: nil)
  }

  var preferredTitle: String {
    String(localized: "Battery")
  }

  var isEnabled: Bool {
    BatteryMonitor.shared.hasBattery
  }

  var view: some View {
    BatterySettingView(state: .shared)
      .frame(width: 400)
  }
}

struct BatterySettingView: View {
  @StateObject var state: AppState

  private var batteryColor: Color {
    BatteryMonitor.shared.currentCapacity >= AppState.shared.batteryLowThreshold ? .blue : .red
  }

  private var batteryText: String {
    state.batteryMonitorEnable
      ? String(localized: "Deactivate prevention when battery level below:")
      : String(localized: "Deactivate prevention when battery level is low")
  }

  var body: some View {
    Form {
      Toggle(batteryText, isOn: $state.batteryMonitorEnable)
        .onChange(of: state.batteryMonitorEnable) { _, enable in
          guard enable,
                BatteryMonitor.shared.currentCapacity < AppState.shared.batteryLowThreshold
          else {
            return
          }
          stopCaffeinate()
        }

      if state.batteryMonitorEnable {
        VStack(alignment: .leading) {
          BatterySlider(minValue: 10,
                        maxValue: 90,
                        currentValue: $state.batteryLowThreshold,
                        enabled: $state.batteryMonitorEnable)
          HStack {
            Text("Current battery capacity: \(BatteryMonitor.shared.currentCapacity)%")
              .font(.caption)
            Image(systemName: BatteryMonitor.shared.capacitySymbol)
              .foregroundColor(batteryColor)
          }
          .padding(.vertical, 3)
          Text("If manually activate prevention, this setting will be ignored.")
            // https://stackoverflow.com/a/59277022/5350993
            .fixedSize(horizontal: false, vertical: true)
            .settingPropmt()
        }
        .padding(.horizontal)
      }

      Divider()
      Toggle("Deactivate prevention when Low Power Mode", isOn: $state.lowPowerMonitorEnable)
        .onChange(of: state.lowPowerMonitorEnable) { _, enable in
          guard enable, BatteryMonitor.shared.isLowPowerModeEnabled else { return }
          stopCaffeinate()
        }
      Text("Automatically deactivate prevention when Mac's Low Power Mode is activated.")
        .settingPropmt()
      Divider()
      Toggle("Activate prevention when charging", isOn: $state.activatePlug)
        .onChange(of: state.activatePlug) { _, activate in
          guard activate, BatteryMonitor.shared.isCharging else { return }
          CaffeinateController.shared.startIfAllowed()
        }
      Text("Automatically activate prevention when Mac is connected to the charger.")
        .settingPropmt()
      Toggle("Deactivate prevention when not charging", isOn: $state.deactivateUnplug)
        .onChange(of: state.deactivateUnplug) { _, deactivate in
          guard deactivate, !BatteryMonitor.shared.isCharging else { return }
          stopCaffeinate()
        }
      Text("Automatically deactivate prevention when Mac isn't connected to the charger.")
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
