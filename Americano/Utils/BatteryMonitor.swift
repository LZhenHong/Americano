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
