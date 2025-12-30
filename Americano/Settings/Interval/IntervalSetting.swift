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

  var body: some View {
    VStack(spacing: 0) {
      // Toolbar
      HStack(spacing: 8) {
        Button {
          state.awakeDurations.sort()
        } label: {
          Image(systemName: "arrow.up.arrow.down")
        }
        .help("Sort by time")

        Button(role: .destructive) {
          showResetAlert.toggle()
        } label: {
          Image(systemName: "arrow.counterclockwise")
        }
        .help("Reset to default")

        Spacer()

        Button {
          markIntervalAsDefault(selectedInterval)
        } label: {
          Image(systemName: "star")
        }
        .disabled(!canIntervalSetToDefault(selectedInterval))
        .help("Set as default")

        Button {
          showPickerSheet.toggle()
        } label: {
          Image(systemName: "plus")
        }
        .help("Add duration")

        Button {
          delete(interval: selectedInterval)
        } label: {
          Image(systemName: "minus")
        }
        .disabled(!canIntervalBeDeleted(selectedInterval))
        .help("Remove duration")
      }
      .padding(.horizontal, SettingsDesignTokens.cardPadding)
      .padding(.vertical, 8)
      .background(SettingsDesignTokens.cardBackgroundColor)

      Divider()

      // Duration List
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
      .listStyle(.inset)
      .scrollContentBackground(.hidden)
    }
    .background(SettingsDesignTokens.cardBackgroundColor)
    .cornerRadius(SettingsDesignTokens.cardCornerRadius)
    .padding(SettingsDesignTokens.formPadding)
    .sheet(isPresented: $showPickerSheet, onDismiss: didDismiss) {
      CustomIntervalView(interval: $interval) { time in
        if time > 0, state.awakeDurations.has(time) {
          return String(localized: "\(time.localizedTime) already exists.")
        }
        return nil
      }
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
    .frame(width: SettingsDesignTokens.settingsPaneWidth, height: 320)
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
      Button(role: .destructive) {
        delete(interval: interval)
      } label: {
        Text("Delete")
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
        .font(interval.default ? .system(size: 14, weight: .semibold) : .system(size: 14))
      Spacer()
      if interval.default {
        Label("Default", systemImage: "star.fill")
          .font(.caption)
          .foregroundStyle(.orange)
      }
    }
    .padding(.vertical, 4)
    .deleteDisabled(!interval.deletable)
  }
}

#if DEBUG
#Preview {
  IntervalSettingView(state: .sample)
}
#endif
