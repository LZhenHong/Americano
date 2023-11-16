//
//  TimeInterval+.swift
//  Americano
//
//  Created by Eden on 2023/11/16.
//

import Foundation

let dateFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = DateComponentsFormatter.UnitsStyle.full
    return formatter
}()

extension TimeInterval {
    var localizedTime: String {
        isInfinite ? "∞" : dateFormatter.string(from: self) ?? ""
    }
}
