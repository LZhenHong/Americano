//
//  BatterySlider.swift
//  Americano
//
//  Created by Eden on 2024/1/30.
//

import SwiftUI

struct BatterySlider: View {
  let minValue: Int
  let maxValue: Int
  @Binding var currentValue: Int
  @Binding var enabled: Bool

  var averageValue: Int {
    (minValue + maxValue) / 2
  }

  var numberOfTickMarks: Int {
    (maxValue - minValue) / 10 + 1
  }

  var body: some View {
    VStack {
      Slider(
        value: Binding(
          get: {
            Double(currentValue)
          },
          set: {
            currentValue = Int($0)
          }
        ),
        in: Double(minValue)...Double(maxValue),
        step: 10
      )
      .disabled(!enabled)

      HStack {
        Text("\(minValue)%")
        Spacer()
        Text("\(averageValue)%")
        Spacer()
        Text("\(maxValue)%")
      }
      .font(.caption)
    }
  }
}

#Preview {
  BatterySlider(minValue: 10,
                maxValue: 90,
                currentValue: .constant(40),
                enabled: .constant(true))
    .padding()
}
