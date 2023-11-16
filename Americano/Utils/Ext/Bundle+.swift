//
//  Bundle+.swift
//  Americano
//
//  Created by Eden on 2023/11/16.
//

import Foundation

extension Bundle {
    var appName: String? {
        return object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    var appVersion: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var buildVersion: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
