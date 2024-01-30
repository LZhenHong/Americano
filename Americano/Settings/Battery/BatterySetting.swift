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
        case 0..<25:
            return "battery.25percent"
        case 25..<50:
            return "battery.50percent"
        case 50..<75:
            return "battery.75percent"
        case 75..<100:
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
        BatterySettingView()
            .frame(width: 400)
            .eraseToAnyView()
    }
}

struct BatterySettingView: View {
    var body: some View {
        HStack {}
    }
}

#Preview {
    BatterySettingView()
}
