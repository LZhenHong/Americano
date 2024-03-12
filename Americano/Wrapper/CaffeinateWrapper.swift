//
//  CaffeinateWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Foundation
import os.log

let ONE_MINUTE_IN_SECONDS = 60

protocol CaffeinateDelegate: AnyObject {
    func caffeinateDidStart(_ caffeinate: CaffeinateWrapper, interval: TimeInterval)
    func caffeinateDidTerminate(_ caffeinate: CaffeinateWrapper)
    func caffeinateAutoTerminate(_ caffeinate: CaffeinateWrapper)
}

// caffeinate Man Page: https://ss64.com/osx/caffeinate.html
final class CaffeinateWrapper: BinWrapper {
    weak var delegate: CaffeinateDelegate?

    private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                                category: String(describing: CaffeinateWrapper.self))

    private var caffeinate: Process?

    var process: Process? {
        caffeinate
    }

    var binPath: String {
        "/usr/bin/caffeinate"
    }

    @discardableResult
    func start(
        interval: TimeInterval = .infinity,
        allowDisplaySleep: Bool = false,
        force: Bool = false
    ) -> Bool {
        guard caffeinate == nil || !running || force else {
            // There was already a process running.
            return false
        }
        stopCurrent()
        return start(interval: interval)
    }

    private func stopCurrent() {
        guard let caffeinate else { return }

        caffeinate.terminate()
        caffeinate.waitUntilExit()
        caffeinate.terminationHandler = nil
        self.caffeinate = nil
    }

    private func start(interval: TimeInterval, allowDisplaySleep: Bool = false) -> Bool {
        caffeinate = newProcess()
        guard interval > 0, let caffeinate else {
            return false
        }

        let pid = ProcessInfo.processInfo.processIdentifier
        var args = allowDisplaySleep ? ["-i"] : ["-di"]
        args += ["-w", "\(pid)"]
        if interval.isFinite {
            args += ["-t", "\(interval)"]
        }
        caffeinate.arguments = args

        do {
            try caffeinate.run()

            delegate?.caffeinateDidStart(self, interval: interval)
            AppState.shared.preventSleep = true

            if interval.isFinite {
                observeCaffeinateProcessExit()
            }
            return true
        } catch {
            logger.warning("Start caffeinate process fail: \(error)")
        }
        return false
    }

    private func observeCaffeinateProcessExit() {
        guard let caffeinate else { return }

        caffeinate.terminationHandler = { [weak self] _ in
            guard let self else { return }

            DispatchQueue.main.async {
                self.stop()
                self.delegate?.caffeinateAutoTerminate(self)
            }
        }
    }

    func stop() {
        guard caffeinate != nil else { return }

        stopCurrent()

        delegate?.caffeinateDidTerminate(self)
        AppState.shared.preventSleep = false
    }

    deinit {
        stop()
    }
}
