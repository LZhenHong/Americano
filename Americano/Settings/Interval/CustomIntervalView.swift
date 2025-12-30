//
//  CustomIntervalView.swift
//  Americano
//
//  Created by Eden on 2023/11/15.
//

import SwiftUI

struct CustomIntervalView: View {
  @Environment(\.dismiss) var dismiss

  @Binding var interval: AwakeDurations.Interval
  let intervalValidator: (TimeInterval) -> String?

  @State private var hoursText: String = ""
  @State private var minutesText: String = ""
  @State private var secondsText: String = ""
  @State private var asDefault = false

  @FocusState private var focusedField: Field?

  private enum Field {
    case hours, minutes, seconds
  }

  private var hours: Int { Int(hoursText) ?? 0 }
  private var minutes: Int { Int(minutesText) ?? 0 }
  private var seconds: Int { Int(secondsText) ?? 0 }

  private var isIntervalInvalid: Bool {
    hours == 0 && minutes == 0 && seconds == 0
  }

  private var currentInterval: TimeInterval {
    TimeInterval(hours * TimeConstants.secondsPerHour + minutes * TimeConstants.secondsPerMinute + seconds)
  }

  private var previewText: String {
    if isIntervalInvalid {
      return String(localized: "Enter a duration")
    }
    return currentInterval.localizedTime
  }

  var body: some View {
    VStack(spacing: SettingsDesignTokens.sectionSpacing) {
      // Header
      Text("Add Custom Duration", comment: "Dialog title")
        .font(.headline)

      // Time Input Fields
      HStack(spacing: 12) {
        TimeInputField(
          label: String(localized: "Hours"),
          text: $hoursText,
          placeholder: "0",
          maxValue: TimeConstants.maxHours
        )
        .focused($focusedField, equals: .hours)

        Text(":")
          .font(.title2)
          .foregroundStyle(.secondary)

        TimeInputField(
          label: String(localized: "Min", comment: "Minutes abbreviation"),
          text: $minutesText,
          placeholder: "00",
          maxValue: TimeConstants.maxMinutesOrSeconds
        )
        .focused($focusedField, equals: .minutes)

        Text(":")
          .font(.title2)
          .foregroundStyle(.secondary)

        TimeInputField(
          label: String(localized: "Sec", comment: "Seconds abbreviation"),
          text: $secondsText,
          placeholder: "00",
          maxValue: TimeConstants.maxMinutesOrSeconds
        )
        .focused($focusedField, equals: .seconds)
      }
      .padding(SettingsDesignTokens.cardPadding)
      .background(SettingsDesignTokens.cardBackgroundColor)
      .cornerRadius(SettingsDesignTokens.cardCornerRadius)

      // Duration Preview
      HStack {
        Text("Duration:", comment: "Label for duration preview")
          .foregroundStyle(.secondary)
        Spacer()
        Text(previewText)
          .fontWeight(isIntervalInvalid ? .regular : .semibold)
          .foregroundStyle(isIntervalInvalid ? .secondary : .primary)
      }

      // Set as Default Toggle
      Toggle("Set as default", isOn: $asDefault)
        .toggleStyle(.checkbox)
        .help(Text("Set as default", comment: "Toggle help"))

      // Validation Error
      if let description = intervalValidator(currentInterval) {
        Label(description, systemImage: "exclamationmark.triangle.fill")
          .font(.caption)
          .foregroundStyle(.red)
          .fixedSize(horizontal: false, vertical: true)
      }

      Divider()

      // Action Buttons
      HStack {
        Button("Cancel", role: .cancel) {
          interval = interval(from: 0)
          dismiss()
        }
        .keyboardShortcut(.escape)

        Spacer()

        Button("Add") {
          interval = interval(from: currentInterval)
          dismiss()
        }
        .keyboardShortcut(.return)
        .disabled(isIntervalInvalid || intervalValidator(currentInterval) != nil)
        .buttonStyle(.borderedProminent)
      }
    }
    .padding(SettingsDesignTokens.formPadding)
    .frame(minWidth: 280)
    .onAppear {
      focusedField = .hours
    }
  }

  private func interval(from duration: TimeInterval) -> AwakeDurations.Interval {
    AwakeDurations.Interval(time: duration, default: asDefault)
  }
}

// MARK: - Time Input Field

private struct TimeInputField: View {
  let label: String
  @Binding var text: String
  let placeholder: String
  let maxValue: Int

  var body: some View {
    VStack(spacing: 4) {
      Text(label)
        .font(.caption)
        .foregroundStyle(.secondary)

      TextField(placeholder, text: $text)
        .textFieldStyle(.plain)
        .font(.system(size: 24, weight: .medium, design: .rounded))
        .multilineTextAlignment(.center)
        .frame(width: 50)
        .padding(.vertical, 8)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(6)
        .onChange(of: text) { _, newValue in
          // Only allow digits
          let filtered = newValue.filter(\.isNumber)
          // Limit to maxValue
          if let value = Int(filtered), value > maxValue {
            text = String(maxValue)
          } else {
            text = filtered
          }
        }
    }
  }
}
