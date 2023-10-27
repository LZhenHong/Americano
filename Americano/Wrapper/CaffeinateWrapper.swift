//
//  CaffeinateWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Foundation
import os.log

let ONE_MINUTE_IN_SECONDS = 60

// caffeinate Man Page: https://ss64.com/osx/caffeinate.html
final class CaffeinateWrapper: BinWrapper {
    private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                                category: "CaffeinateController")

    private var caffeinate: Process?

    var process: Process? {
        get {
            caffeinate
        }
    }

    var binPath: String {
        get {
            "/usr/bin/caffeinate"
        }
    }

    @discardableResult
    func start(time: TimeInterval = .infinity, override: Bool = false) -> Bool {
        guard caffeinate == nil || !running || override else {
            // There was already a process running.
            return false
        }
        stopCurrent()
        return start(time: time)
    }

    private func stopCurrent() {
        guard let caffeinate else {
            return
        }
        caffeinate.terminate()
        caffeinate.waitUntilExit()
        caffeinate.terminationHandler = nil
        self.caffeinate = nil
    }
    
    private func start(time: TimeInterval) -> Bool {
        caffeinate = newProcess()
        guard time > 0, let caffeinate else {
            return false
        }

        let pid = ProcessInfo.processInfo.processIdentifier
        var args = ["-diu", "-w", "\(pid)"]
        if time.isFinite {
            args += ["-t", "\(time)"]
        }
        caffeinate.arguments = args

        do {
            try caffeinate.run()
            
            AppState.shared.preventSleep = true
            if time.isFinite {
                observeCaffeinateProcessExit()
            }

            return true
        } catch {
            logger.warning("Start caffeinate process fail: \(error)")
        }
        return false
    }

    private func observeCaffeinateProcessExit() {
        guard let caffeinate else {
            return
        }
        caffeinate.terminationHandler = { [weak self] _ in
            guard let self else {
                return
            }
            self.stop()
        }

//        let runner = { [weak self] in
//            guard let self,
//                  let caffeinate = self.caffeinate else {
//                AppState.shared.preventSleep = false
//                return
//            }
//            caffeinate.waitUntilExit()
//            self.stop()
//        }
//        Task {
//            runner()
//        }
//        DispatchQueue.global(qos: .background).async {
//            runner()
//        }
    }

    func stop() {
        guard let _ = self.caffeinate else {
            return
        }
        stopCurrent()
        AppState.shared.preventSleep = false
    }

    deinit {
        stop()
    }
}
