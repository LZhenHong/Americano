//
//  AwakeDurations.swift
//  Americano
//
//  Created by Eden on 2023/10/26.
//

import Foundation

public struct AwakeDurations: RawRepresentable {
    public struct Interval: Codable, Equatable {
        let time: TimeInterval
        private (set) var `default` = false

        mutating func markAsDefault() {
            `default` = true
        }

        mutating func resetDefault() {
            `default` = false
        }

        public static func == (lhs: Interval, rhs: Interval) -> Bool {
            lhs.time == rhs.time
        }
    }

    private(set) var intervals: [Interval] = []

    private var defaultIntervals: [Interval] {
        [
            Interval(time: .infinity, default: true),
            Interval(time: 5 * 60),
            Interval(time: 10 * 60),
            Interval(time: 30 * 60),
            Interval(time: 60 * 60),
            Interval(time: 3 * 60 * 60)
        ]
    }

    public var rawValue: String {
        intervals.rawValue
    }

    public init?(rawValue: String) {
        let intervals = Array<Interval>(rawValue: rawValue) ?? []
        self.init(intervals)
    }

    public init(_ intervals: [Interval] = []) {
        self.intervals = intervals.isEmpty ? defaultIntervals : intervals
    }

    mutating func appendInterval(_ time: TimeInterval, as default: Bool = false) -> Bool {
        var interval = Interval(time: time, default: `default`)
        guard !intervals.contains(interval) else {
            return false
        }

        if `default` {
            interval.markAsDefault()
            for idx in intervals.indices {
                intervals[idx].resetDefault()
            }
        }
        intervals.append(interval)
        return true
    }

    mutating func removeInterval(at index: Int) {
        guard intervals.indices.contains(index) else {
            return
        }
        intervals.remove(at: index)
    }

    mutating func removeInterval(_ interval: Interval) {
        guard let index = intervals.firstIndex(of: interval) else {
            return
        }
        removeInterval(at: index)
    }
}
