//
//  Storage.swift
//  Americano
//
//  Created by LZhenHong on 2023/9/21.
//

import Foundation

@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T

    private var userStorage: UserDefaults {
        UserDefaults.standard
    }

    var wrappedValue: T {
        set {
            let data = try? JSONEncoder().encode(newValue)
            userStorage.set(data, forKey: key)
        }
        get {
            guard let data = userStorage.object(forKey: key) as? Data else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
    }

    init(key: String, defalutValue: T) {
        self.key = key
        self.defaultValue = defalutValue
    }
}
