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

## Design Context

### Users

Americano serves macOS users who need to prevent their Mac from sleeping during tasks like downloads, presentations, or long-running processes. The target audience skews toward a broad base of Mac users — including developers, designers, students, and general productivity users — but is designed to be approachable for anyone.

- **Context**: Users install a small utility and expect it to "just work" without friction.
- **Job to be done**: Keep the Mac awake when needed, with minimal interaction.
- **Time commitment**: Very low — onboarding should take under 30 seconds.

### Brand Personality

**Focused. Reliable. Restrained.**

Americano is a tool, not a toy. It should feel like a natural extension of macOS — confident in its simplicity, never demanding attention. The emotional goal is calm trust: users know it's there, working, without needing to think about it.

### Aesthetic Direction

- **Visual tone**: Brutally minimal and native-first. No decorative gradients, no glassmorphism, no custom colors fighting the system. Rely entirely on macOS system colors, SF Symbols, and standard AppKit/SwiftUI patterns.
- **Light/dark**: Both, fully system-adaptive via `NSColor` semantic colors.
- **References**: Apple System Preferences, standard macOS utility apps (e.g., Raycast settings, standard Xcode preference panes).
- **Anti-references**: Anything that looks like a web app wrapped in a window. No neon accents, no purple gradients, no custom icon sets, no rounded-rectangle cards with shadows.

### Design Principles

1. **Invisibility is the goal**: The best onboarding teaches users just enough to feel confident, then gets out of the way. The app lives in the menu bar — the UI should never compete for attention.
2. **Native over novel**: Use standard macOS controls, standard spacing, standard typography. Custom visual flourishes betray a utility's credibility.
3. **One thought per screen**: If onboarding requires multiple steps, each step communicates exactly one idea. No feature dumps.
4. **Respect the skip**: Experienced users must be able to dismiss onboarding instantly and never see it again. Track dismissal state in `AppState`.
5. **Show the menu bar**: Since the entire app lives in the menu bar, onboarding must explicitly orient users to the cup icon — left-click for menu, right-click to toggle.
