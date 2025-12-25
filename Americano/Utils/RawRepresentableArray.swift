//
//  RawRepresentableArray.swift
//  Americano
//
//  Created by Eden on 2024/12/12.
//

import Foundation
import os.log

private let logger = Logger(subsystem: AppDelegate.bundleIdentifier,
                            category: "RawRepresentableArray")

@propertyWrapper
struct RawRepresentableArray<Element>: RawRepresentable where Element: Codable {
  typealias RawValue = String

  private var value: [Element] = []

  var wrappedValue: [Element] {
    get { value }
    set { value = newValue }
  }

  init(wrappedValue: [Element]) {
    value = wrappedValue
  }

  var rawValue: RawValue {
    do {
      let encoder = JSONEncoder()
      encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "inf",
                                                                    negativeInfinity: "-inf",
                                                                    nan: "NaN")
      let data = try encoder.encode(value)
      let val = String(data: data, encoding: .utf8)
      return val ?? "[]"
    } catch {
      logger.error("Encode error: \(error)")
      return "[]"
    }
  }

  init?(rawValue: RawValue) {
    do {
      let data = rawValue.data(using: .utf8)
      guard let data else {
        return nil
      }

      let decoder = JSONDecoder()
      decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "inf",
                                                                      negativeInfinity: "-inf",
                                                                      nan: "NaN")
      let val = try decoder.decode([Element].self, from: data)
      value = val
    } catch {
      logger.error("Decode error: \(error)")
      return nil
    }
  }
}
