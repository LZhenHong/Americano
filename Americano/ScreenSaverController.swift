//
//  ScreenSaverController.swift
//  Americano
//
//  Created by Eden on 2023/9/21.
//

import Foundation
import os.log

final class ScreenSaverController: BinWrapper {
    let logger = Logger(subsystem: "io.lzhlovesjyq.Americano", category: "ScreenSaverController")
    
    var binPath: String {
        get {
            "/usr/bin/open"
        }
    }

    @discardableResult
    func run() -> Bool {
        let screenSaver = newProcess()
        screenSaver.arguments = ["-a", "ScreenSaverEngine"]
        do {
            try screenSaver.run()
            screenSaver.waitUntilExit()
            return true
        } catch {
            logger.warning("Enter screen saver fail: \(error)")
        }
        return false
    }
}
