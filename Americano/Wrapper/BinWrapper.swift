//
//  BinWrapper.swift
//  Americano
//
//  Created by Eden on 2023/9/21.
//

import Foundation

/// Protocol for wrapping command-line executable processes.
///
/// Provides a common interface for managing subprocess lifecycle,
/// including path validation, process creation, and running state.
protocol BinWrapper {
  /// Path to the executable binary.
  var binPath: String { get }
  /// The underlying process instance, if created.
  var process: Process? { get }
}

extension BinWrapper {
  var process: Process? {
    nil
  }

  /// Whether the process is currently running.
  var running: Bool {
    guard let running = process?.isRunning else {
      return false
    }
    return running
  }

  /// Whether the executable exists at the specified path.
  var isValid: Bool {
    FileManager.default.fileExists(atPath: binPath)
  }

  /// Creates a new Process configured with the executable path.
  /// - Returns: A new Process instance ready for configuration and execution.
  func newProcess() -> Process {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: binPath)
    return process
  }
}
