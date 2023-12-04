//
//  SubMenuBuilder.swift
//  Americano
//
//  Created by Eden on 2023/12/4.
//

import Cocoa

enum SubMenuBuilder {
    static func build(with intervals: [AwakeDurations.Interval]) -> NSMenu {
        NSMenu {
            for interval in intervals {
                MenuItemBuilder()
                    .title(interval.localizedTime)
                    .onSelect {
                        AppDelegate.caffWrapper.start(
                            interval: interval.time,
                            allowDisplaySleep: AppState.shared.allowDisplaySleep
                        )
                    }
            }
        }
    }
}
