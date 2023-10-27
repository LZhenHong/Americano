//
//  Array+Raw.swift
//  Americano
//
//  Created by Eden on 2023/10/27.
//

import Foundation

extension Array: RawRepresentable where Element: Codable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let val = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return val
    }

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let val = try? JSONDecoder().decode([Element].self, from: data) else {
            return nil
        }
        self = val
    }
}
