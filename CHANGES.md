# Changes

User-facing release history for Americano. Follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For Sparkle delta detail (with HTML release notes) see `appcast.xml`.
For internal engineering decisions see `docs/adr/`.

## [Unreleased]

### Infrastructure
- Hardened `.github/workflows/release.yml`: workflow now runs under a `concurrency`
  group (prevents two simultaneous `workflow_dispatch` runs from racing on the
  same `vX.Y.Z` tag) and verifies all required secrets up-front (`DEEPSEEK_API_KEY`,
  `SPARKLE_PRIVATE_KEY`, and `TAP_GITHUB_TOKEN` when Homebrew update is on) before
  spending CI minutes on an archive build.
- Established documentation structure under `docs/`: ADRs for the release
  pipeline, versioning model, and ad-hoc code-signing trade-off; baseline
  snapshots of architecture and the release pipeline; a postmortem template.

### Fixed
- `AppDelegate.bundleIdentifier` fallback string had a typo (`io.lzhlovesjqy.Americano`
  → `io.lzhlovesjyq.Americano`). This affected only the `os.Logger` subsystem
  label in the rare case `Bundle.main.bundleIdentifier` is `nil`; no user-visible
  impact.

## [1.0.8] — 2026-04-27

### Added
- Onboarding welcome window on first launch.

### Fixed
- Low Power Mode handling and observer lifecycle.
- Memory safety in battery monitoring.

### Infrastructure
- Automated release workflow: GitHub Actions builds, signs Sparkle appcast,
  publishes GitHub Release, and updates the Homebrew tap.
- AI-generated changelog via DeepSeek embedded into appcast `<description>`
  through Sparkle's basename convention.

## [1.0.7] — 2025-12-30

### Changed
- Settings UI redesigned with unified card layout and broader i18n.

### Fixed
- IOKit battery callback memory management hardened (`passRetained`).
- Resolved retain cycle in `MenuItemBuilder` by externalizing subscriptions.

## [1.0.3] — 2025-12-30

### Added
- `CustomIntervalView` footer layout polish.

### Changed
- Settings views refactored with reusable components.

## [1.0.0] — 2025-03-10

Initial public release.

[Unreleased]: https://github.com/LZhenHong/Americano/compare/v1.0.8...HEAD
[1.0.8]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.8
[1.0.7]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.7
[1.0.3]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.3
[1.0.0]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.0
