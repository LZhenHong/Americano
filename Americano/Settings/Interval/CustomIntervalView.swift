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

    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var asDefault = false

    private var isIntervalInvalid: Bool {
        hours == 0 && minutes == 0 && seconds == 0
    }

    private var currentInterval: TimeInterval {
        TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }

    var body: some View {
        VStack {
            Text("Add Custom Interval")
                .font(.title3)
            VStack(alignment: .trailing) {
                IntervalComponent(prompt: "Hours", maxValue: 999, value: $hours)
                IntervalComponent(prompt: "Minutes", value: $minutes)
                IntervalComponent(prompt: "Seconds", value: $seconds)
            }
            .padding(.top, 10)
            Toggle("Set as default", isOn: $asDefault)
                .padding(.bottom, 10)

            if let description = intervalValidator(currentInterval) {
                Text(description)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
            }

            HStack {
                Button("Cancel") {
                    interval = interval(from: 0)
                    dismiss()
                }
                Spacer()
                Button("Add") {
                    interval = interval(from: currentInterval)
                    dismiss()
                }
                .disabled(isIntervalInvalid)
            }
        }
        .padding()
        .frame(width: 280)
    }

    private func interval(from duration: TimeInterval) -> AwakeDurations.Interval {
        AwakeDurations.Interval(time: duration, default: asDefault)
    }
}

private struct IntervalComponent: View {
    var prompt: LocalizedStringResource
    var maxValue: Int = 59
    @Binding var value: Int
    @State private var stepperValue: Double = 0

    var body: some View {
        Stepper(String(localized: prompt), value: $stepperValue, in: 0...Double(maxValue), format: .number) { start in
            if !start {
                value = Int(stepperValue)
            }
        }
    }
}
