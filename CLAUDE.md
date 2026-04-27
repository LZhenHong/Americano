# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Americano is a macOS menu bar app that prevents Mac from sleeping by wrapping the system `caffeinate` command. Built with AppKit (no SwiftUI for main UI), it uses Combine for reactive state management.

**Minimum Deployment Target**: macOS 14.0

## Build & Run

Open `Americano.xcodeproj` in Xcode and build. SPM dependencies are resolved automatically.

To build from command line:
```bash
xcodebuild -project Americano.xcodeproj -scheme Americano build
```

## Architecture

### Core Flow
- `main.swift` → `AppDelegate` → initializes `CaffeinateController` and `MenuBarItemController`
- On first launch, `OnboardingWindowController` presents the welcome window
- App runs as a menu bar item only (no dock icon, no main window)

### Key Singletons

- **`AppState`** (`Data/AppState.swift`): Observable state container using the `@storage` macro from `StorageMacro` SPM package for automatic persistence. All app preferences flow through here.
- **`CaffeinateController`** (`Main/CaffeinateController.swift`): Business logic for caffeinate activation/deactivation, battery monitoring integration, and URL scheme handling.
- **`MenuBarItemController`** (`Main/MenuBarItemController.swift`): Manages the `NSStatusItem` (menu bar icon). Left-click shows menu, right-click toggles caffeinate.
- **`BatteryMonitor`** (`Utils/BatteryMonitor.swift`): IOKit-based power source monitoring for battery-aware caffeinate control.

### Onboarding

- **`OnboardingWindowController`** (`Onboarding/OnboardingWindowController.swift`): Manages the welcome window presentation.
- **`OnboardingView`** (`Onboarding/OnboardingView.swift`): SwiftUI view for first-launch onboarding. Shows app identity, interaction guide (left-click vs right-click), and quick setup toggle for `activateOnLaunch`.
- Dismissal state tracked in `AppState.hasSeenOnboarding`. Users can re-open onboarding from Settings > About.

### Wrapper Layer

- **`BinWrapper`** protocol (`Wrapper/BinWrapper.swift`): Abstraction for spawning command-line processes.
- **`CaffeinateWrapper`** (`Wrapper/CaffeinateWrapper.swift`): Manages `/usr/bin/caffeinate` process lifecycle with delegate callbacks (`CaffeinateDelegate`).
- **`ScreenSaverWrapper`** (`Wrapper/ScreenSaverWrapper.swift`): Spawns `ScreenSaverEngine` via `/usr/bin/open` when caffeinate auto-terminates (if `activateScreenSaver` is enabled).

### Menu System

Uses custom `@resultBuilder` DSL for declarative menu construction:
- `MenuBuilder` (`Utils/MenuBuilder.swift`): Result builder for `NSMenu`
- `MenuItemBuilder` (`Utils/MenuItemBuilder.swift`): Fluent builder for `NSMenuItem` with Combine-based enable/disable
- `SubMenuBuilder` (`Main/SubMenuBuilder.swift`): Builds duration submenu from `AwakeDurations.intervals`

### Settings

Settings window uses `SettingsWindowController` from `SettingsKit` SPM package, with 5 `SettingsPane` tabs:

| Pane | File | Key Features |
|------|------|-------------|
| General | `Settings/GeneralSetting.swift` | Launch at login, activate on launch, screen saver, display sleep |
| Durations | `Settings/Interval/IntervalSetting.swift` | Add/remove/sort duration presets, set default, custom interval picker |
| Battery | `Settings/Battery/BatterySetting.swift` | Low threshold auto-stop, Low Power Mode monitoring, plug/unplug behavior |
| Notification | `Settings/NotificationSetting.swift` | Permission status, activate/deactivate notifications |
| About | `Settings/AboutSetting.swift` | App version, re-open onboarding, Sparkle update check |

Design system: `SettingsDesignTokens` (`Utils/SettingsDesignTokens.swift`) provides spacing, dimensions, and reusable components (`SettingsCard`, `SettingToggleRow`, `SettingsCardStyle`).

### Utilities

- **`SubscriptionToken`** (`Utils/SubscriptionToken.swift`): Lightweight single-subscription holder for Combine. Use `.seal(in:)` on `AnyCancellable` instead of `Set<AnyCancellable>` when only one subscription needs management.
- **`URLSchemeUtils` / `URLSchemeInvoker`** (`Utils/URLSchemeUtils.swift`): Registers Apple Event handlers for `americano://` URL schemes. Routes path-based commands with query parameter parsing.
- **`UserNotifications`** (`Utils/UserNotifications.swift`): Wraps `UNUserNotificationCenter` for requesting permission and posting activate/deactivate alerts.
- **`LaunchAtLogin`** (`Utils/LaunchAtLogin.swift`): Thin wrapper around `SMAppService` for login item registration.

### Data Layer

- **`AwakeDurations`** (`Data/AwakeDurations.swift`): Configurable duration preset collection using `@RawRepresentableArray` property wrapper for `String`-based persistence. Supports default marking, custom intervals, sorting, and validation.

## SPM Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| [StorageMacro](https://github.com/LZhenHong/StorageMacro) | `@storage` macro for automatic `ObservableObject` + `UserDefaults` persistence | 0.0.3 |
| [SettingsKit](https://github.com/LZhenHong/SettingsKit.git) | Settings window framework with `SettingsPane` protocol | 0.0.3 |
| [Sparkle](https://github.com/sparkle-project/Sparkle) | Auto-update framework | 2.7.0 |
| [swift-syntax](https://github.com/apple/swift-syntax.git) | StorageMacro dependency | 509.1.1 |

## Compilation Flags

- `USE_SPARKLE`: Enables Sparkle auto-update framework (set in `Config.xcconfig`)

## URL Schemes

Registered in `CaffeinateController.registerURLSchemes()` via `URLSchemeInvoker`:
- `americano:///activate?hours=&minutes=&seconds=` — Activates with optional duration. Empty params = default duration.
- `americano:///deactivate` — Stops sleep prevention.
- `americano:///toggle` — Toggles sleep prevention on/off.

## Localization

String resources in `Resources/Localizable.xcstrings`. Use `String(localized:)` for new strings. The app supports multiple languages through Xcode's localization system.

## Scripts

Release tooling in `Scripts/`:
- `bump-version.sh`: Build number auto-increment (runs via Xcode scheme pre-action)
- `compile-release.sh`: Build release archive
- `gen-cast.sh`: Generate Sparkle appcast, commit, and tag

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
