//
//  Bundle+.swift
//  Americano
//
//  Created by Eden on 2023/11/16.
//

import Foundation

extension Bundle {
    var appName: String? {
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    var appVersion: String? {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var buildVersion: String? {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
