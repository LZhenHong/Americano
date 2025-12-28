# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Americano is a macOS menu bar app that prevents Mac from sleeping by wrapping the system `caffeinate` command. Built with AppKit (no SwiftUI for main UI), it uses Combine for reactive state management.

**Minimum Deployment Target**: macOS 14.0

## Build & Run

Open `Americano.xcodeproj` in Xcode and build. No external package manager needed—SPM dependencies are resolved automatically.

To build from command line:
```bash
xcodebuild -project Americano.xcodeproj -scheme Americano build
```

## Architecture

### Core Flow
- `main.swift` → `AppDelegate` → initializes `CaffeinateController` and `MenuBarItemController`
- App runs as a menu bar item only (no dock icon, no main window)

### Key Singletons
- **`AppState`** (`Data/AppState.swift`): Observable state container using `@storage` macro for persistence. All app preferences flow through here.
- **`CaffeinateController`** (`Main/CaffeinateController.swift`): Business logic for caffeinate activation/deactivation, battery monitoring integration, and URL scheme handling.
- **`MenuBarItemController`** (`Main/MenuBarItemController.swift`): Manages the NSStatusItem (menu bar icon). Left-click shows menu, right-click toggles caffeinate.
- **`BatteryMonitor`** (`Utils/BatteryMonitor.swift`): IOKit-based power source monitoring for battery-aware caffeinate control.

### Wrapper Layer
- **`BinWrapper`** protocol: Abstraction for spawning command-line processes
- **`CaffeinateWrapper`**: Manages `/usr/bin/caffeinate` process lifecycle with delegate callbacks

### Menu System
Uses custom `@resultBuilder` DSL for declarative menu construction:
- `MenuBuilder`: Result builder for `NSMenu`
- `MenuItemBuilder`: Fluent builder for `NSMenuItem` with Combine-based enable/disable

### Settings
Settings window uses `SettingWindowController` with multiple `SettingContentRepresentable` tabs (General, Interval, Battery, Notification, About).

## Compilation Flags

- `USE_SPARKLE`: Enables Sparkle auto-update framework (set in `Config.xcconfig`)

## URL Schemes

Registered in `CaffeinateController.registerURLSchemes()`:
- `americano:///activate?hours=&minutes=&seconds=`
- `americano:///deactivate`
- `americano:///toggle`

## Localization

String resources in `Resources/Localizable.xcstrings`. Use `String(localized:)` for new strings.

## Scripts

Release tooling in `Scripts/`:
- `bump-version.sh`: Version/build number management
- `compile-release.sh`: Build release archive
- `gen-cast.sh`: Generate Sparkle appcast
