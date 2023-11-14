//
//  CustomIntervalView.swift
//  Americano
//
//  Created by Eden on 2023/11/15.
//

import SwiftUI

struct CustomIntervalView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var interval: TimeInterval

    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0

    private var isIntervalInvalid: Bool {
        hours == 0 && minutes == 0 && seconds == 0
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
            .padding()
            HStack {
                Button("Cancel") {
                    interval = 0
                    dismiss()
                }
                Spacer()
                Button("Add") {
                    interval = TimeInterval(hours * 3600 + minutes * 60 + seconds)
                    dismiss()
                }
                .disabled(isIntervalInvalid)
            }
        }
        .padding()
        .frame(width: 280)
    }
}

private struct IntervalComponent: View {
    var prompt: String
    var maxValue: Int = 59
    @Binding var value: Int
    @State private var stepperValue: Double = 0

    var body: some View {
        Stepper(prompt, value: $stepperValue, in: 0...Double(maxValue), format: .number) { start in
            if !start {
                value = Int(stepperValue)
            }
        }
    }
}
