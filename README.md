# Americano

Americano is a macOS menu bar app that prevents your Mac from sleeping — handy during downloads, presentations, or any long-running task.

<img src="Images/screenshot.png" />

## Features

- **Menu Bar Integration** — Lives in your menu bar with a single cup icon. Left-click opens the menu, right-click quickly toggles sleep prevention.
- **Flexible Durations** — Choose from preset durations or create your own custom intervals. Set a default duration for one-click activation.
- **Battery Awareness** — Automatically stop sleep prevention when battery drops below a threshold, when Low Power Mode activates, or based on charger connection status.
- **Notifications** — Optional macOS notifications when sleep prevention activates or deactivates.
- **Launch at Login** — Start automatically when you log in, with optional immediate activation.
- **Auto-Update** — Built-in Sparkle framework checks for updates automatically.
- **Onboarding** — Welcome window on first launch explains menu bar interaction and quick setup.
- **URL Schemes** — Control the app programmatically via custom URL schemes.

## URL Schemes

> [!NOTE]
> You need to launch Americano first.

* **Activate** (with optional duration): `americano:///activate?hours={hours}&minutes={minutes}&seconds={seconds}`
  * Example: `americano:///activate?hours=1&minutes=30` — Activates for 1 hour 30 minutes
  * Example: `americano:///activate` — Activates with the default duration
* **Deactivate**: `americano:///deactivate`
* **Toggle**: `americano:///toggle`

## Settings

Open from the menu bar menu (**⌘,**).

| Pane | Highlights |
|------|-----------|
| General | Launch at login, activate on launch, screen saver, display sleep |
| Durations | Add/remove/sort presets, set default |
| Battery | Auto-stop by battery level, Low Power Mode, charger status |
| Notification | Permission + activate/deactivate alerts |
| About | Version info, re-open onboarding, check for updates |

## System requirements

- macOS 14.0 and later

## How to build

1. Clone this repo:

   ```bash
   git clone git@github.com:LZhenHong/Americano.git
   ```

2. Open `Americano.xcodeproj` with Xcode.

3. Use your own Team and change the Bundle Identifier.

<img src="Images/build.png" />

## Dependencies

Americano uses the following Swift Package Manager dependencies:

- [StorageMacro](https://github.com/LZhenHong/StorageMacro) — Automatic `UserDefaults` persistence via `@storage` macro
- [SettingsKit](https://github.com/LZhenHong/SettingsKit) — Settings window framework
- [Sparkle](https://github.com/sparkle-project/Sparkle) — Auto-update framework

## Contributions

Pull requests and issues are welcome! If you encounter any issues or have suggestions for improvement, feel free to submit an issue.

## License

This project is licensed under the [MIT License][1].

> [!NOTE]
> If you are using **Bartender**, **Ice**, or similar menu bar management apps and have hidden the Americano icon, the status display of the menu bar icon may be inaccurate.

[1]: https://github.com/LZhenHong/Americano/blob/main/LICENSE
