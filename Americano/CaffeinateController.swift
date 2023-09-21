//
//  CaffeinateController.swift
//  Americano
//
//  Created by Eden on 2023/9/20.
//

import Foundation
import os.log

let ONE_MINUTE_IN_SECONDS = 60

// caffeinate Man Page: https://ss64.com/osx/caffeinate.html
final class CaffeinateController {
    private let logger = Logger(subsystem: "io.lzhlovesjyq.Americano",
                                category: "CaffeinateController")

    private var caffeinate: Process?

    var running: Bool {
        guard let running = caffeinate?.isRunning else {
            return false
        }
        return running
    }

    var caffeinateBinPath: String {
        get {
            "/usr/bin/caffeinate"
        }
    }

    var isValid: Bool {
        get {
            FileManager.default.fileExists(atPath: caffeinateBinPath)
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
        self.caffeinate = nil
    }
    
    private func start(time: TimeInterval) -> Bool {
        caffeinate = newCaffeinateProcess()
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
            
            AppDelegate.appState.preventSleep = true
            if time.isFinite {
                observeCaffeinateProcessExit()
            }

            return true
        } catch {
            logger.warning("Start caffeinate process fail: \(error)")
        }
        return false
    }

    private func newCaffeinateProcess() -> Process? {
        let process = Process()
        process.launchPath = caffeinateBinPath
        return process
    }

    private func observeCaffeinateProcessExit() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self,
                  let caffeinate = self.caffeinate else {
                AppDelegate.appState.preventSleep = false
                return
            }
            caffeinate.waitUntilExit()
            self.stop()
        }
    }

    func stop() {
        guard running else {
            return
        }
        stopCurrent()
        AppDelegate.appState.preventSleep = false
    }
}
