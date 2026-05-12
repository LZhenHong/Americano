# Changes

User-facing release history for Americano. Follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For Sparkle delta detail (with HTML release notes) see `appcast.xml`.

## [Unreleased]

_No changes yet._

## [1.0.9] — 2026-05-12

### Fixed
- `AppDelegate.bundleIdentifier` fallback string had a typo (`io.lzhlovesjqy.Americano`
  → `io.lzhlovesjyq.Americano`). This affected only the `os.Logger` subsystem
  label in the rare case `Bundle.main.bundleIdentifier` is `nil`; no user-visible
  impact.

### Infrastructure
- Hardened `.github/workflows/release.yml`: workflow now runs under a `concurrency`
  group (prevents two simultaneous `workflow_dispatch` runs from racing on the
  same `vX.Y.Z` tag) and verifies all required secrets up-front (`DEEPSEEK_API_KEY`,
  `SPARKLE_PRIVATE_KEY`, and `TAP_GITHUB_TOKEN` when Homebrew update is on) before
  spending CI minutes on an archive build.
- CI build now passes `-skipMacroValidation` and `CODE_SIGNING_ALLOWED=NO` so the
  unsigned Swift macro plugins (`StorageMacro` / `swift-syntax`) compile cleanly
  on GitHub-hosted runners.
- Cached `Build/SourcePackages`, `Build/Build/Intermediates.noindex`,
  `Build/Build/Products`, and `~/Library/Caches/org.swift.swiftpm` across runs,
  and removed the `Clean` step so SPM checkouts and previously compiled
  dependencies (swift-syntax, Sparkle) are reused.
- GitHub Release now also uploads `Releases/Americano.app.html` alongside the
  zip and appcast for easier human inspection of the AI-generated release notes.

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

[Unreleased]: https://github.com/LZhenHong/Americano/compare/v1.0.9...HEAD
[1.0.9]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.9
[1.0.8]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.8
[1.0.7]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.7
[1.0.3]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.3
[1.0.0]: https://github.com/LZhenHong/Americano/releases/tag/v1.0.0
