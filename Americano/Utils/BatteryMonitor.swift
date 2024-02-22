//
//  BatteryMonitor.swift
//  Americano
//
//  Created by Eden on 2024/1/9.
//

import Cocoa
import Combine
import IOKit.ps

final class BatteryState: ObservableObject {
    @Published var isLowPowerModeEnabled = false
    @Published var isCharging = false
    @Published var currentCapacity = 0
}

final class BatteryMonitor {
    private(set) var state = BatteryState()
    private let token = SubscriptionToken()

    private var loopSource: CFRunLoopSource?

    private var powerSourceInfo: [String: Any] {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [[String: Any]],
              let source = sources.first
        else {
            return [:]
        }
        return source
    }

    private var isListeningPowerSourceInfo: Bool {
        loopSource != nil
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

    var capacitySymbol: String {
        isCharging ?"battery.100percent.bolt" : currentCapacityImageName
    }

    private var currentCapacityImageName: String {
        switch currentCapacity {
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

    init() {
        setUpStates()
    }

    private func setUpStates() {
        state.isLowPowerModeEnabled = isLowPowerModeEnabled
        state.isCharging = isCharging
        state.currentCapacity = currentCapacity
    }

    func observeOnBatteryState() {
        guard !isListeningPowerSourceInfo else { return }

        let ctx = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        loopSource = IOPSNotificationCreateRunLoopSource({ context in
            guard let ctx = context else { return }

            let monitor = Unmanaged<BatteryMonitor>.fromOpaque(ctx).takeUnretainedValue()
            monitor.state.isCharging = monitor.isCharging
            monitor.state.currentCapacity = monitor.currentCapacity
        }, ctx).takeRetainedValue()
        CFRunLoopAddSource(CFRunLoopGetCurrent(), loopSource, .defaultMode)
    }

    func observeOffBatteryState() {
        guard isListeningPowerSourceInfo, let source = loopSource else { return }

        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
    }

    func observeOnLowPowerMode() {
        guard !token.isValid else { return }

        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.state.isLowPowerModeEnabled = self.isLowPowerModeEnabled
            }
            .seal(in: token)
    }

    func observeOffLowPowerMode() {
        token.unseal()
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
