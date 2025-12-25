//
//  TimeInterval+.swift
//  Americano
//
//  Created by Eden on 2023/11/16.
//

import Foundation

extension TimeInterval {
  var localizedTime: String {
    if isInfinite { return "∞" }
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    return formatter.string(from: self) ?? ""
  }
}
