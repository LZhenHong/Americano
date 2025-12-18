//
//  IntervalSetting.swift
//  Americano
//
//  Created by Eden on 2023/10/19.
//

import SettingsKit
import SwiftUI

struct IntervalSetting: SettingsPane {
  var tabViewImage: NSImage? {
    NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
  }

  var preferredTitle: String {
    String(localized: "Durations")
  }

  var view: some View {
    IntervalSettingView(state: .shared)
  }
}

private struct IntervalSettingView: View {
  @ObservedObject var state: AppState

  @State private var selectedInterval: AwakeDurations.Interval?

  @State private var showPickerSheet = false
  @State private var selectedDate = Date()
  @State private var interval = AwakeDurations.Interval(time: 0)

  @State private var showResetAlert = false

  var listView: some View {
    List(selection: $selectedInterval) {
      ForEach(state.awakeDurations.intervals) { interval in
        IntervalSettingCell(interval: interval)
          .tag(interval)
          .contextMenu {
            contextMenu(for: interval)
          }
      }
      .onDelete(perform: delete(at:))
    }
    .cornerRadius(10)
    .padding(8)
  }

  var operationView: some View {
    HStack {
      Button("Sort by time") {
        state.awakeDurations.sort()
      }
      Button {
        showResetAlert.toggle()
      } label: {
        Text("Reset")
          .foregroundStyle(.red)
      }
      Spacer()
      Button("Set default") {
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
    .padding(.bottom, 15)
    .padding(.horizontal, 10)
  }

  var intervalPickerView: some View {
    CustomIntervalView(interval: $interval) { time in
      if time > 0, state.awakeDurations.has(time) {
        return String(localized: "\(time.localizedTime) already exists.")
      }
      return nil
    }
  }

  var body: some View {
    VStack {
      listView
      operationView
    }
    .sheet(isPresented: $showPickerSheet, onDismiss: didDismiss) {
      intervalPickerView
    }
    .alert("Reset to default", isPresented: $showResetAlert) {
      Button("Reset", role: .destructive) {
        selectedInterval = nil
        state.awakeDurations.restoreDefaultIntervals()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This will remove all custom durations.")
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

  @ViewBuilder
  private func contextMenu(for interval: AwakeDurations.Interval) -> some View {
    if !interval.default {
      Button("Set default") {
        markIntervalAsDefault(interval)
      }
      .disabled(!canIntervalSetToDefault(interval))
      Divider()
      Button {
        delete(interval: interval)
      } label: {
        Text("Delete")
          .foregroundStyle(.red)
      }
      .disabled(!interval.deletable)
    }
  }

  private func markIntervalAsDefault(_ interval: AwakeDurations.Interval?) {
    guard let interval else { return }

    state.awakeDurations.markAsDefault(interval: interval)

    /// workaround: Magic to trigger UI refresh.
    selectedInterval = nil
    var temp = interval
    temp.markAsDefault()
    selectedInterval = temp
  }

  private func didDismiss() {
    guard interval.time > 0 else { return }

    state.awakeDurations.append(interval.time, as: interval.default)
  }

  private func delete(at indexSet: IndexSet) {
    guard let index = indexSet.first else { return }

    let interval = state.awakeDurations.removeInterval(at: index)
    clearSelectionIfNeeded(interval)
  }

  private func delete(interval: AwakeDurations.Interval?) {
    guard let interval else { return }

    state.awakeDurations.remove(interval: interval)
    clearSelectionIfNeeded(interval)
  }

  private func clearSelectionIfNeeded(_ interval: AwakeDurations.Interval?) {
    guard let selectedInterval, let interval, selectedInterval == interval else { return }

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

#if DEBUG
#Preview {
  IntervalSettingView(state: .sample)
}
#endif
