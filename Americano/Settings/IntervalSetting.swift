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

    private var isSelectingDefault: Bool {
        guard let selectedInterval else {
            return true
        }
        return selectedInterval.default
    }

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
            .disabled(isSelectingDefault)
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
            .disabled(isSelectingDefault)
        }
    }

    var intervalPickerView: some View {
        CustomIntervalView()
    }

    var body: some View {
        VStack {
            List(selection: $selectedInterval) {
                ForEach(state.awakeDurations.intervals) { interval in
                    IntervalSettingCell(interval: interval)
                        .tag(interval)
                        .contextMenu(contextMenu(for: interval))
                }
                .onDelete(perform: delete)
            }
            .cornerRadius(10)
            .padding(8)

            operationView
                .padding(.bottom, 15)
                .padding(.horizontal, 10)
        }
        .sheet(isPresented: $showPickerSheet) {
            intervalPickerView
        }
        .frame(width: 400, height: 350)
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
                .disabled(interval.default)
                Divider()
                Button("Delete") {
                    delete(interval: interval)
                }
                .disabled(interval.default)
            }
            .eraseToAnyView()
        }
    }

    private func markIntervalAsDefault(_ interval: AwakeDurations.Interval?) {
        guard let interval else {
            return
        }
        state.awakeDurations.markAsDefault(interval: interval)
    }

    private func delete(at indexSet: IndexSet) {
        guard indexSet.count == 1 else {
            return
        }
        let index = indexSet.first!
        state.awakeDurations.removeInterval(at: index)
    }

    private func delete(interval: AwakeDurations.Interval?) {
        guard let interval else {
            return
        }
        state.awakeDurations.remove(interval: interval)
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
        .deleteDisabled(interval.default)
    }
}

private struct CustomIntervalView: View {
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0

    var body: some View {
        VStack {
            Text("Add Custom Interval")
            HStack {
                TextField("Hours", value: $hours, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Minutes", value: $minutes, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Seconds", value: $seconds, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
    }
}

#Preview {
    IntervalSettingView(state: .sample)
}
