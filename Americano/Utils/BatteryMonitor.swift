//
//  BatteryMonitor.swift
//  Americano
//
//  Created by Eden on 2024/1/9.
//

import Cocoa
import IOKit.ps

final class BatteryMonitor {
    private let token = SubscriptionToken()

    private var powerSourceInfo: [String: Any] {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [[String: Any]],
              let source = sources.first
        else {
            return [:]
        }
        return source
    }

    var isLowPowerModeEnabled: Bool {
        ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var hasBattery: Bool {
        guard let batteryType = powerSourceInfo[kIOPSTypeKey] as? String else {
            return false
        }
        return batteryType == kIOPSInternalBatteryType
    }

    var isCharging: Bool {
        guard let charging = powerSourceInfo[kIOPSIsChargingKey] as? Bool else {
            return false
        }
        return charging
    }

    var currentCapacity: Int {
        guard let capacity = powerSourceInfo[kIOPSCurrentCapacityKey] as? Int else {
            return 0
        }
        return capacity
    }

    func setUp() {
        registerPublisher()
    }

    private func registerPublisher() {
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.batteryStateDidChange()
            }
            .seal(in: token)
    }

    @objc private func batteryStateDidChange() {
//        let isLowPower = isLowPowerModeEnabled
    }
}

extension BatteryMonitor: CustomStringConvertible {
    var description: String {
        """
        BatteryMonitor:
            isLowPowerModeEnabled: \(isLowPowerModeEnabled)
            hasBattery: \(hasBattery)
            isCharging: \(isCharging)
            currentCapacity: \(currentCapacity)
        """
    }
}

// https://github.com/NSHipster/nshipster.cn/blob/master/_posts/2015-04-13-unmanaged.md
