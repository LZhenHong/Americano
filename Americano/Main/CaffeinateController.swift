//
//  CaffeinateController.swift
//  Americano
//
//  Created by Eden on 2024/2/1.
//

import Combine
import Foundation
import os.log

final class CaffeinateController {
    static let shared = CaffeinateController()

    let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                        category: String(describing: CaffeinateController.self))
    let caffWrapper: CaffeinateWrapper

    private var lowPowerToken = SubscriptionToken()
    private var batteryInfoSubscriptions = Set<AnyCancellable>()

    private var allowDisplaySleep: Bool {
        AppState.shared.allowDisplaySleep
    }

    private var canActivate: Bool {
        if AppState.shared.batteryMonitorEnable,
           AppDelegate.batteryMonitor.currentCapacity <= AppState.shared.batteryLowThreshold
        {
            return false
        }

        if AppState.shared.lowPowerMonitorEnable,
           AppDelegate.batteryMonitor.isLowPowerModeEnabled
        {
            return false
        }

        if AppState.shared.deactivateUnplug,
           !AppDelegate.batteryMonitor.isCharging
        {
            return false
        }

        return true
    }

    private var shouldObservePowerInfo: Bool {
        if AppState.shared.batteryMonitorEnable,
           AppDelegate.batteryMonitor.currentCapacity > AppState.shared.batteryLowThreshold
        {
            return true
        }

        if AppState.shared.activatePlug || AppState.shared.deactivateUnplug {
            return true
        }

        return false
    }

    private init() {
        caffWrapper = CaffeinateWrapper()
        caffWrapper.delegate = self
    }

    func setUp() {
        activateIfNeed()
        observeBatteryLowPowerModeIfNeed()
        observeBatteryPowerInfoIfNeed()
    }

    private func activateIfNeed() {
        guard AppState.shared.activateOnLaunch, canActivate else { return }

        startIfAllowed()
        logger.info("Activate on Launch.")
    }

    func observeBatteryLowPowerModeIfNeed() {
        guard AppState.shared.lowPowerMonitorEnable else { return }

        AppDelegate.batteryMonitor.observeOnLowPowerMode()
        AppDelegate.batteryMonitor.state.$isLowPowerModeEnabled
            .filter(!)
            .sink { _ in
                self.stop()
            }
            .seal(in: lowPowerToken)
    }

    func stopObserveBatteryLowPowerMode() {
        AppDelegate.batteryMonitor.observeOffLowPowerMode()
        lowPowerToken.unseal()
    }

    func observeBatteryPowerInfoIfNeed() {
        guard shouldObservePowerInfo else { return }

        AppDelegate.batteryMonitor.observeOnBatteryState()

        observeBatteryToStartCaffeinate()
        observeBatteryToStopCaffeinate()
    }

    private func observeBatteryToStartCaffeinate() {
        AppDelegate.batteryMonitor.state.$isCharging
            .filter { $0 && AppState.shared.activatePlug && !self.caffWrapper.running }
            .sink { _ in
                self.startIfAllowed()
            }
            .store(in: &batteryInfoSubscriptions)
    }

    private func observeBatteryToStopCaffeinate() {
        let chargeStopPulisher = AppDelegate.batteryMonitor.state.$isCharging
            .filter { !$0 && AppState.shared.deactivateUnplug }
        let batteryCapacityPulisher = AppDelegate.batteryMonitor.state.$currentCapacity
            .map { capacity in
                AppState.shared.batteryMonitorEnable && capacity <= AppState.shared.batteryLowThreshold
            }
            .filter { $0 }
        chargeStopPulisher.merge(with: batteryCapacityPulisher)
            .filter { _ in self.caffWrapper.running }
            .sink { _ in
                self.stop()
            }
            .store(in: &batteryInfoSubscriptions)
    }

    func stopObserveBatteryPowerInfo() {
        AppDelegate.batteryMonitor.observeOffBatteryState()
        batteryInfoSubscriptions.removeAll()
    }

    func toggle() {
        if caffWrapper.running {
            stop()
        } else {
            start()
        }
    }

    func startIfAllowed() {
        guard canActivate else { return }

        start()
    }

    @discardableResult
    func start() -> Bool {
        let interval = AppState.shared.awakeDurations.default.time
        return start(interval: interval)
    }

    @discardableResult
    func start(interval: TimeInterval, force: Bool = false) -> Bool {
        return caffWrapper.start(interval: interval, allowDisplaySleep: allowDisplaySleep, force: force)
    }

    func stop() {
        caffWrapper.stop()
    }
}

extension CaffeinateController: CaffeinateDelegate {
    func caffeinateAutoTerminate(_ caffeinate: CaffeinateWrapper) {
        if AppState.shared.activateScreenSaver {
            AppDelegate.screenWrapper.run()
        }
    }
}
