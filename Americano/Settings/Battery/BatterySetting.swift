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
      .frame(width: SettingsDesignTokens.settingsPaneWidth)
  }
}

struct BatterySettingView: View {
  @ObservedObject var state: AppState

  private var batteryColor: Color {
    BatteryMonitor.shared.currentCapacity >= AppState.shared.batteryLowThreshold ? .blue : .red
  }

  private var batteryText: LocalizedStringKey {
    state.batteryMonitorEnable
      ? "Deactivate prevention when battery level below:"
      : "Deactivate prevention when battery level is low"
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: SettingsDesignTokens.sectionSpacing) {
        // MARK: - Battery Level Monitoring Section

        GroupBox {
          VStack(alignment: .leading, spacing: SettingsDesignTokens.cardItemSpacing) {
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
              VStack(alignment: .leading, spacing: 8) {
                BatterySlider(
                  minValue: 10,
                  maxValue: 90,
                  currentValue: $state.batteryLowThreshold,
                  enabled: $state.batteryMonitorEnable
                )

                HStack(spacing: 4) {
                  Text("Current battery capacity: \(BatteryMonitor.shared.currentCapacity)%")
                    .font(.caption)
                  Image(systemName: BatteryMonitor.shared.capacitySymbol)
                    .foregroundStyle(batteryColor)
                }

                Text("If manually activate prevention, this setting will be ignored.")
                  .fixedSize(horizontal: false, vertical: true)
                  .settingDescription()
              }
              .padding(.top, SettingsDesignTokens.toggleDescriptionSpacing)
            }
          }
        } label: {
          Label("Battery Level", systemImage: "battery.50percent")
        }
        .groupBoxStyle(SettingsCardStyle())

        // MARK: - Low Power Mode Section

        GroupBox {
          SettingToggleRow(
            "Deactivate prevention when Low Power Mode",
            description: "Automatically deactivate prevention when Mac's Low Power Mode is activated.",
            isOn: $state.lowPowerMonitorEnable
          ) { enable in
            guard enable, BatteryMonitor.shared.isLowPowerModeEnabled else { return }
            stopCaffeinate()
          }
        } label: {
          Label("Low Power Mode", systemImage: "leaf")
        }
        .groupBoxStyle(SettingsCardStyle())

        // MARK: - Charging Behavior Section

        GroupBox {
          VStack(alignment: .leading, spacing: SettingsDesignTokens.cardItemSpacing) {
            SettingToggleRow(
              "Activate prevention when charging",
              description: "Automatically activate prevention when Mac is connected to the charger.",
              isOn: $state.activatePlug
            ) { activate in
              guard activate, BatteryMonitor.shared.isCharging else { return }
              CaffeinateController.shared.startIfAllowed()
            }

            SettingToggleRow(
              "Deactivate prevention when not charging",
              description: "Automatically deactivate prevention when Mac isn't connected to the charger.",
              isOn: $state.deactivateUnplug
            ) { deactivate in
              guard deactivate, !BatteryMonitor.shared.isCharging else { return }
              stopCaffeinate()
            }
          }
        } label: {
          Label("Charging", systemImage: "bolt.fill")
        }
        .groupBoxStyle(SettingsCardStyle())
      }
      .padding(SettingsDesignTokens.formPadding)
    }
    .scrollBounceBehavior(.basedOnSize)
  }

  private func stopCaffeinate() {
    CaffeinateController.shared.stop()
    CaffeinateController.shared.stopObserveBatteryPowerInfoIfShould()
  }
}

#if DEBUG
#Preview {
  BatterySettingView(state: .sample)
    .frame(width: SettingsDesignTokens.settingsPaneWidth)
}
#endif
