//
//  AwakeDurations.swift
//  Americano
//
//  Created by Eden on 2023/10/26.
//

import Foundation

public struct AwakeDurations: RawRepresentable {
    public struct Interval: Codable, Equatable, Identifiable, Hashable {
        public var id: TimeInterval {
            time
        }

        static let infinity = Interval(time: .infinity)

        let time: TimeInterval
        private(set) var `default` = false

        var deletable: Bool {
            !`default` && !isInfinite
        }

        var isInfinite: Bool {
            time.isInfinite
        }

        var localizedTime: String {
            time.localizedTime
        }

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

    var `default`: Interval {
        intervals.first { $0.default } ?? .infinity
    }

    public var rawValue: String {
        intervals.rawValue
    }

    public init?(rawValue: String) {
        let intervals = [Interval](rawValue: rawValue) ?? []
        self.init(intervals)
    }

    public init(_ intervals: [Interval] = []) {
        self.intervals = intervals.isEmpty ? defaultIntervals : intervals
    }

    func has(_ time: TimeInterval) -> Bool {
        return intervals.contains { $0.time == time }
    }

    func has(_ interval: Interval) -> Bool {
        return intervals.contains(interval)
    }

    @discardableResult
    mutating func append(_ time: TimeInterval, as default: Bool = false) -> Bool {
        let interval = Interval(time: time, default: `default`)
        guard !intervals.contains(interval) else {
            return false
        }

        intervals.append(interval)
        if `default` {
            markAsDefault(interval: interval)
        }
        return true
    }

    @discardableResult
    mutating func removeInterval(at index: Int) -> Interval? {
        guard intervals.indices.contains(index) else {
            return nil
        }
        return intervals.remove(at: index)
    }

    @discardableResult
    mutating func remove(interval: Interval) -> Interval? {
        guard let index = intervals.firstIndex(of: interval) else {
            return nil
        }
        return removeInterval(at: index)
    }

    mutating func restoreDefaultIntervals() {
        intervals = defaultIntervals
    }

    @discardableResult
    mutating func markAsDefault(interval: Interval) -> Bool {
        guard let index = intervals.firstIndex(of: interval) else {
            return false
        }
        for idx in intervals.indices {
            intervals[idx].resetDefault()
        }
        intervals[index].markAsDefault()
        return true
    }

    mutating func sort() {
        intervals.sort {
            if $0.default != $1.default {
                return $0.default
            }
            if $0.isInfinite != $1.isInfinite {
                return $0.isInfinite
            }
            return $0.time < $1.time
        }
    }
}
