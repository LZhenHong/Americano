//
//  CaffeinateController.swift
//  Americano
//
//  Created by Eden on 2024/2/1.
//

import Foundation
import os.log

final class CaffeinateController {
    static let shared = CaffeinateController()

    let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                        category: "CaffeinateController")

    let caffWrapper: CaffeinateWrapper

    private var allowDisplaySleep: Bool {
        AppState.shared.allowDisplaySleep
    }

    private init() {
        caffWrapper = CaffeinateWrapper()
        caffWrapper.delegate = self
    }

    func setUp() {
        guard AppState.shared.activateOnLaunch else {
            return
        }
        /// Activate on Launch
        start()
        logger.info("Activate on Launch.")
    }

    func toggle() {
        // Start a infinite caffeinate process.
        if caffWrapper.running {
            stop()
        } else {
            start()
        }
    }

    @discardableResult
    func start() -> Bool {
        let interval = AppState.shared.awakeDurations.default.time
        return caffWrapper.start(interval: interval, allowDisplaySleep: allowDisplaySleep)
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
