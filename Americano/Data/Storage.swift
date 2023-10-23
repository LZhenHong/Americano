//
//  Storage.swift
//  Americano
//
//  Created by Eden on 2023/9/21.
//

import Foundation

/// SwiftUI has `AppStorage` propertyWrapper also, this just for practice.

@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let storage: UserDefaults

    var wrappedValue: T {
        set {
            let data = try? JSONEncoder().encode(newValue)
            storage.set(data, forKey: key)
        }
        get {
            guard let data = storage.object(forKey: key) as? Data else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
    }

    init(key: String, defalutValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defalutValue
        self.storage = storage
    }
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "\(AppDelegate.bundleIdentifier).userdefaults")!
}
