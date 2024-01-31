//
//  BatterySlider.swift
//  Americano
//
//  Created by Eden on 2024/1/30.
//

import Cocoa
import SwiftUI

struct WrapSlider: NSViewRepresentable {
    typealias NSViewType = NSSlider

    let minValue: Int
    let maxValue: Int
    let numberOfTickMarks: Int
    @Binding var currentValue: Int
    @Binding var enabled: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider(target: context.coordinator,
                              action: #selector(Coordinator.valueChanged))
        slider.sliderType = .linear
        slider.minValue = Double(minValue)
        slider.maxValue = Double(maxValue)
        slider.numberOfTickMarks = numberOfTickMarks
        slider.allowsTickMarkValuesOnly = true
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        nsView.integerValue = currentValue
        nsView.isEnabled = enabled
    }

    class Coordinator: NSObject {
        var slider: WrapSlider

        init(_ slider: WrapSlider) {
            self.slider = slider
        }

        @objc func valueChanged(_ sender: NSSlider) {
            slider.currentValue = sender.integerValue
        }
    }
}

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
            WrapSlider(minValue: minValue,
                       maxValue: maxValue,
                       numberOfTickMarks: numberOfTickMarks,
                       currentValue: $currentValue,
                       enabled: $enabled)
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
