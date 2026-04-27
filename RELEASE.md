# Release Workflow

This document describes how to build, version, and publish a new release of Americano.

## Overview

Americano uses a hybrid approach:

- **Build number** (`BUILD_NUMBER`) — auto-incremented on every build via Xcode pre-action.
- **Semantic version** (`VERSION`) — manually controlled in `Config.xcconfig`.
- **Distribution** — Sparkle auto-update via GitHub Releases + `appcast.xml`.

## Version Configuration

Single source of truth:

```
Americano/Resources/Config.xcconfig
  VERSION      = 1.0.8        ← marketing version (you edit this)
  BUILD_NUMBER = 20260427005  ← auto-incremented by pre-action script
```

Xcode project wires these into the app bundle:

```
Config.xcconfig ──► project.pbxproj ──► Info.plist
  VERSION            MARKETING_VERSION      CFBundleShortVersionString
  BUILD_NUMBER       CURRENT_PROJECT_VERSION   CFBundleVersion
```

### Build Number Format

`YYYYMMDD` + 3-digit counter, reset daily.

Example: `20260427005` = April 27, 2026, 5th build of the day.

## Build-Time Auto Bump

On every Xcode build, the scheme pre-action runs `Scripts/bump-version.sh`:

1. Reads current `BUILD_NUMBER` from `Config.xcconfig`.
2. Increments the daily counter.
3. Writes the new build number back.

**Semantic version is NOT auto-bumped.** You must manually edit `VERSION` in `Config.xcconfig` when you decide to ship a new version.

## Release Steps

### 1. Set the Version

Edit `Americano/Resources/Config.xcconfig` and update `VERSION` to the desired value.

```xcconfig
VERSION = 1.0.9
```

Build number will auto-increment on the next build — no need to touch it.

### 2. Build Release Archive

```bash
./Scripts/compile-release.sh [optional-target-dir]
```

What it does:

1. Cleans `Build/`, `Archive/`, `*.xcarchive`, `*.zip`.
2. Runs `xcodebuild archive` in Release configuration.
3. Produces `Americano.xcarchive`.
4. Zips `Americano.app` into `Releases/Americano.app.zip`.

Output:

```
Releases/
  └── Americano.app.zip
```

### 3. Write Release Notes

Create `Releases/Americano.app.html` (same base name as the zip, `.html` extension). `generate_appcast` automatically picks it up and embeds it into the appcast entry.

Content guidelines:

- **Do not** include `<!DOCTYPE>` or `<body>` tags — keep it as HTML fragments so Sparkle embeds them directly into `appcast.xml` as CDATA.
- Use headings, lists, and inline styles as needed.

Example:

```html
<h2>Version 1.0.8</h2>

<h3>🐛 Bug Fixes</h3>
<ul>
  <li>Fixed memory leak in battery monitor</li>
</ul>

<h3>✨ New Features</h3>
<ul>
  <li>Added custom interval presets</li>
</ul>
```

The file lives next to the zip:

```
Releases/
  ├── Americano.app.zip
  └── Americano.app.html
```

### 4. Generate Appcast & Tag

```bash
./Scripts/gen-cast.sh
```

What it does:

1. Reads `CFBundleShortVersionString` from the archived app.
2. Runs Sparkle `generate_appcast` against `Releases/` to produce/update `appcast.xml`.
3. Commits `appcast.xml` with message `[UPDATE] Version X.Y.Z.`.
4. Creates a signed Git tag `vX.Y.Z`.

Prerequisites:

- `generate_appcast` must be available at `./Build/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast` (resolved automatically by SPM).
- The archive `Americano.xcarchive` must exist from the previous step.

### 5. Push & Create GitHub Release

```bash
git push
git push --tags
```

Then create a GitHub Release from tag `vX.Y.Z` and attach `Releases/Americano.app.zip` as the release asset.

The `appcast.xml` enclosure URL points to:

```
https://github.com/LZhenHong/Americano/releases/download/vX.Y.Z/Americano.app.zip
```

Make sure the release asset name matches exactly.

### 6. Verify Sparkle Feed

The app checks this URL on launch:

```
https://raw.githubusercontent.com/LZhenHong/Americano/main/appcast.xml
```

Since `appcast.xml` is committed to `main`, users will pick up the new version automatically.

## Sparkle Setup

| Item | Value |
|------|-------|
| Framework | Sparkle 2.x via SPM |
| Feed URL | `https://raw.githubusercontent.com/LZhenHong/Americano/main/appcast.xml` |
| Public Key | `SUPublicEDKey` in `Info.plist` |
| Compilation flag | `USE_SPARKLE` (set in `Config.xcconfig`) |

## Scripts Reference

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `Scripts/bump-version.sh` | Auto-increment build number | Automatically on every Xcode build (pre-action) |
| `Scripts/compile-release.sh` | Build Release archive + zip | Before publishing |
| `Scripts/gen-cast.sh` | Generate appcast, commit, tag | After `compile-release.sh` |

## Notes

- Do **not** set `BUMP_VERSION` in the scheme environment — semantic version bumping was removed to avoid accidental version increments during release builds.
- The release scripts set local proxy env vars (`http://127.0.0.1:6152`) for network access. Remove or adjust if your environment differs.
- `appcast.xml` is tracked in Git on `main`. Ensure it is pushed after `gen-cast.sh` runs.
