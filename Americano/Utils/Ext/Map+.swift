//
//  Map+.swift
//  Americano
//
//  Created by Eden on 2024/2/23.
//

import Foundation

extension Dictionary where Value == String {
    func intValue(for key: Key) -> Int {
        guard let value = self[key] else { return 0 }
        return Int(value) ?? 0
    }
}
