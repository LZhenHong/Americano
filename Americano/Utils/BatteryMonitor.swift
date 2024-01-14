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
    private var runloop: CFRunLoop?

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

    init() {
        setUpStates()
    }

    private func setUpStates() {
        state.isLowPowerModeEnabled = isLowPowerModeEnabled
        state.isCharging = isCharging
        state.currentCapacity = currentCapacity
    }

    func start() {
        observeBatteryState()
        observeLowPowerMode()
    }

    private func observeBatteryState() {
        let ctx = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let source = IOPSNotificationCreateRunLoopSource({ context in
            guard let ctx = context else {
                return
            }
            let monitor = Unmanaged<BatteryMonitor>.fromOpaque(ctx).takeUnretainedValue()
            monitor.state.isCharging = monitor.isCharging
            monitor.state.currentCapacity = monitor.currentCapacity
        }, ctx).takeRetainedValue()
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
    }

    private func observeLowPowerMode() {
        NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.state.isLowPowerModeEnabled = self.isLowPowerModeEnabled
            }
            .seal(in: token)
    }

    func stop() {
        token.unseal()
        guard let runloop, let source = loopSource else {
            return
        }
        CFRunLoopRemoveSource(runloop, source, .defaultMode)
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
