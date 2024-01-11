//
//  BinWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/21.
//

import Foundation
import os.log

protocol BinWrapper {
    var binPath: String { get }
    var process: Process? { get }
}

extension BinWrapper {
    var process: Process? {
        nil
    }

    var running: Bool {
        guard let running = process?.isRunning else {
            return false
        }
        return running
    }

    var isValid: Bool {
        FileManager.default.fileExists(atPath: binPath)
    }

    func newProcess() -> Process {
        let process = Process()
        process.launchPath = binPath
        return process
    }
}
