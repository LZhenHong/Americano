//
//  IntervalSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SwiftUI

struct IntervalSetting: SettingContentRepresentable {
    var tabViewImage: NSImage? {
        NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
    }

    var preferredTitle: String {
        "Awake Interval"
    }

    var view: AnyView {
        IntervalSettingView(state: .shared)
            .eraseToAnyView()
    }
}

private struct IntervalSettingView: View {
    @ObservedObject var state: AppState

    var body: some View {
        List {
            ForEach(state.awakeDurations.intervals) { interval in
                IntervalSettingCell(interval: interval)
            }
        }
        .frame(width: 400, height: 400)
    }
}

private struct IntervalSettingCell: View {
    var interval: AwakeDurations.Interval

    var body: some View {
        HStack {
            Text("\(interval.time) seconds.")
                .frame(height: 35)
                .font(interval.default ? .system(size: 15, weight: .semibold) : .system(size: 14))
            Spacer()
            if interval.default {
                Text("Default")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    IntervalSettingView(state: .sample)
}
