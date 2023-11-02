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
    @State private var selectedInterval: AwakeDurations.Interval?

    var body: some View {
        List {
            ForEach(state.awakeDurations.intervals) { interval in
                IntervalSettingCell(interval: interval)
                    .tag(interval)
                    .contextMenu(!interval.default ? ContextMenu {
                        contextMenuContent(for: interval)
                    } : nil)
            }
            .onDelete(perform: delete)
        }
        .cornerRadius(10)
        .padding(8)
        .frame(width: 400, height: 350)
    }

    @ViewBuilder
    private func contextMenuContent(for interval: AwakeDurations.Interval) -> some View {
        Button("Set Default") {
            markIntervalAsDefault(interval)
        }
        .disabled(interval.default)
        Divider()
        Button("Delete") {
            delete(interval: interval)
        }
        .disabled(interval.default)
    }

    private func markIntervalAsDefault(_ interval: AwakeDurations.Interval) {
        state.awakeDurations.markAsDefault(interval: interval)
    }

    private func delete(at indexSet: IndexSet) {
        guard indexSet.count == 1 else {
            return
        }
        let index = indexSet.first!
        state.awakeDurations.removeInterval(at: index)
    }

    private func delete(interval: AwakeDurations.Interval) {
        state.awakeDurations.remove(interval: interval)
    }
}

private struct IntervalSettingCell: View {
    var interval: AwakeDurations.Interval

    var body: some View {
        HStack {
            Text("\(interval.localizedTime)")
                .frame(height: 35)
                .font(interval.default ? .system(size: 15, weight: .semibold) : .system(size: 14))
            Spacer()
            if interval.default {
                Text("Default")
                    .foregroundColor(.secondary)
            }
        }
        .deleteDisabled(interval.default)
    }
}

#Preview {
    IntervalSettingView(state: .sample)
}
