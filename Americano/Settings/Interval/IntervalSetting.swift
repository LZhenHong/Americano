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
    @State private var showPickerSheet = false
    @State private var selectedDate = Date()
    @State private var interval: TimeInterval = 0

    var operationView: some View {
        HStack {
            Button("Reset") {
                selectedInterval = nil
                state.awakeDurations.restoreDefaultIntervals()
            }
            Spacer()
            Button("Set Default") {
                markIntervalAsDefault(selectedInterval)
            }
            .disabled(!canIntervalSetToDefault(selectedInterval))
            Button {
                showPickerSheet.toggle()
            } label: {
                Image(systemName: "plus")
            }
            Button {
                delete(interval: selectedInterval)
            } label: {
                Image(systemName: "minus")
            }
            .disabled(!canIntervalBeDeleted(selectedInterval))
        }
    }

    var intervalPickerView: some View {
        CustomIntervalView(interval: $interval)
    }

    var body: some View {
        VStack {
            List(selection: $selectedInterval) {
                ForEach(state.awakeDurations.intervals) { interval in
                    IntervalSettingCell(interval: interval)
                        .tag(interval)
                        .contextMenu(contextMenu(for: interval))
                }
                .onDelete(perform: delete(at:))
            }
            .cornerRadius(10)
            .padding(8)

            operationView
                .padding(.bottom, 15)
                .padding(.horizontal, 10)
        }
        .sheet(isPresented: $showPickerSheet, onDismiss: didDismiss) {
            intervalPickerView
        }
        .frame(width: 400, height: 350)
    }

    private func canIntervalSetToDefault(_ interval: AwakeDurations.Interval?) -> Bool {
        guard let interval else {
            return false
        }
        return !interval.default
    }

    private func canIntervalBeDeleted(_ interval: AwakeDurations.Interval?) -> Bool {
        guard let interval else {
            return false
        }
        return interval.deletable
    }

    private func contextMenu(for interval: AwakeDurations.Interval) -> ContextMenu<AnyView>? {
        guard !interval.default else {
            return nil
        }

        return ContextMenu {
            Group {
                Button("Set Default") {
                    markIntervalAsDefault(interval)
                }
                .disabled(!canIntervalSetToDefault(interval))
                Divider()
                Button("Delete") {
                    delete(interval: interval)
                }
                .disabled(!interval.deletable)
            }
            .eraseToAnyView()
        }
    }

    private func markIntervalAsDefault(_ interval: AwakeDurations.Interval?) {
        guard let interval else {
            return
        }
        state.awakeDurations.markAsDefault(interval: interval)

        /// workaround: Magic to trigger UI refresh.
        selectedInterval = nil
        var temp = interval
        temp.markAsDefault()
        selectedInterval = temp
    }

    private func didDismiss() {
        guard interval > 0 else {
            return
        }
        if !state.awakeDurations.append(interval) {
            // TODO: 提示用户添加失败
        }
    }

    private func delete(at indexSet: IndexSet) {
        guard indexSet.count == 1 else {
            return
        }
        let index = indexSet.first!
        let interval = state.awakeDurations.removeInterval(at: index)
        clearSelectionIfNeeded(interval)
    }

    private func delete(interval: AwakeDurations.Interval?) {
        guard let interval else {
            return
        }
        state.awakeDurations.remove(interval: interval)
        clearSelectionIfNeeded(interval)
    }

    private func clearSelectionIfNeeded(_ interval: AwakeDurations.Interval?) {
        guard let selectedInterval, let interval, selectedInterval == interval else {
            return
        }
        self.selectedInterval = nil
    }
}

private struct IntervalSettingCell: View {
    var interval: AwakeDurations.Interval

    var body: some View {
        HStack {
            Text("\(interval.localizedTime)")
                .frame(height: 30)
                .font(interval.default ? .system(size: 15, weight: .semibold) : .system(size: 14))
            Spacer()
            if interval.default {
                Text("Default")
                    .foregroundColor(.secondary)
            }
        }
        .deleteDisabled(!interval.deletable)
    }
}

#Preview {
    IntervalSettingView(state: .sample)
}
