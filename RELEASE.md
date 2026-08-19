# Release Workflow

Americano ships through three channels built from two targets sharing the same sources:

| Channel | Build variant | Update mechanism | Signing |
|---------|---------------|------------------|---------|
| GitHub Releases (direct) | `Americano` target | Sparkle (`appcast.xml` on `main`) | Developer ID + Hardened Runtime + notarization |
| Homebrew Cask | same zip as direct | Sparkle (cask declares `auto_updates true`) | same as direct |
| Mac App Store | `AmericanoMAS` target | App Store | Apple Distribution + App Sandbox |

All releases run **locally** on your Mac — no signing credentials ever leave the local Keychain. There is no CI release workflow.

## Conventions

- **Single version source** — `Americano/Resources/Config.xcconfig` (`VERSION`, `BUILD_NUMBER`, `BUNDLE_IDENTIFIER`) is the base configuration of both targets. A release ships the same `VERSION` on every channel.
- **Build number** — auto-incremented by the Xcode scheme pre-action on every build. Direct and MAS builds may carry different build numbers; MAS only requires the number to increase per upload within a version, which the date-based format satisfies.
- **Same bundle id** — both variants use `io.lzhlovesjyq.Americano`, so settings (standard UserDefaults domain) and the `americano://` URL scheme are shared, and users can switch channels without losing state. Only one copy can be installed at a time.
- **Target deltas** — `AmericanoMAS` differs from `Americano` in exactly four ways:
  1. Entitlements: `Americano/Resources/AmericanoMAS.entitlements` (App Sandbox) instead of the empty `Americano.entitlements`.
  2. No `USE_SPARKLE` compilation flag (Sparkle is linked into the direct target only).
  3. No Sparkle package product link.
  4. Signed for the App Store (Apple Distribution) at export time.
- **Channel ownership** — tags, GitHub Releases, `appcast.xml`, and the Homebrew cask are produced by the direct lane (`release-local.sh`) only. The MAS lane (`release-mas.sh`) uploads a build and nothing else; metadata, screenshots, and submitting for review happen manually in App Store Connect.
- **Privacy manifest** — `Americano/PrivacyInfo.xcprivacy` declares UserDefaults usage (CA92.1) and ships in both variants.

## Version Configuration

Single source of truth:

```
Americano/Resources/Config.xcconfig
  VERSION      = 1.0.9        ← marketing version (you edit this)
  BUILD_NUMBER = 20260512002  ← auto-incremented by pre-action script
```

Xcode project wires these into the app bundle:

```
Config.xcconfig ──► project.pbxproj ──► Info.plist
  VERSION            MARKETING_VERSION      CFBundleShortVersionString
  BUILD_NUMBER       CURRENT_PROJECT_VERSION  CFBundleVersion
```

### Build Number Format

`YYYYMMDD` + 3-digit counter, reset daily.

Example: `20260512002` = May 12, 2026, 2nd build of the day.

## One-Time Local Setup

### Direct channel (GitHub Releases + Sparkle + Homebrew)

1. **Developer ID certificate** — Xcode → Settings → Accounts → *your team* → Manage Certificates → **+** → **Developer ID Application** (Account Holder only). Verify with `security find-identity -v -p codesigning`.
2. **Notarization credentials** — create an App Store Connect API key (Developer role suffices) at App Store Connect → Users and Access → Integrations → App Store Connect API, then:

   ```bash
   xcrun notarytool store-credentials "americano-notary" \
     --key /path/to/AuthKey_XXXXXXXXXX.p8 --key-id <key-id> --issuer <issuer-uuid>
   ```

   The profile name defaults to `americano-notary`; override with `NOTARY_KEYCHAIN_PROFILE` if you chose a different one.
3. **GitHub CLI** — `gh auth login` (used for the GitHub Release and the homebrew-tap push).
4. **Sparkle key** — the EdDSA private key must be in the login keychain (it already is if `generate_keys` ran on this machine). Otherwise export `SPARKLE_PRIVATE_KEY_FILE=/path/to/key` before running the release script. `DEEPSEEK_API_KEY` is optional — without it the changelog is a plain commit list.

### Mac App Store channel

1. **App record** — create the app in App Store Connect with bundle id `io.lzhlovesjyq.Americano` (category: Utilities; privacy: declares no data collected). The first upload fails without it.
2. **Apple Distribution certificate** — Xcode → Settings → Accounts → Manage Certificates → **+** → **Apple Distribution**. Verify with `security find-identity -v -p codesigning`.
3. **App Store Connect API key** — the same key used for notarization works. Provide it to the upload lane via environment:

   ```bash
   export ASC_KEY_ID=<key-id>
   export ASC_ISSUER_ID=<issuer-uuid>
   export ASC_KEY_PATH=/path/to/AuthKey_XXXXXXXXXX.p8
   ```

## Release Steps

### 1. Set the Version

Edit `Americano/Resources/Config.xcconfig` and update `VERSION` to the desired value.

```xcconfig
VERSION = 1.0.10
```

Build number will auto-increment on the next build — no need to touch it.

### 2. Push to Main

```bash
git add Americano/Resources/Config.xcconfig
git commit -m "bump version to 1.0.10"
git push origin main
```

### 3. Direct channel: GitHub Releases + Sparkle + Homebrew

```bash
bash Scripts/release-local.sh
```

The script performs the following automatically:

1. **Preflight** — must run on `main`; checks the Developer ID certificate, `gh` auth, the notarytool keychain profile, and that the tag `vVERSION` doesn't exist locally or on `origin`.
2. **Changelog** — AI-generated via DeepSeek if `DEEPSEEK_API_KEY` is set in the environment; otherwise falls back to a plain `git log` list. Set `SKIP_CHANGELOG=1` to keep hand-written notes already present in `Releases/`. Writes `Releases/Americano.app.html` (auto-embedded by Sparkle as `<description>`) + `Releases/CHANGELOG.md` (used as the GitHub Release body).
3. **Build** — `xcodebuild archive` in Release configuration with `-skipMacroValidation` and `ENABLE_HARDENED_RUNTIME=YES`, then `xcodebuild -exportArchive` with the `developer-id` method (re-signs with the Developer ID certificate). The build number is bumped by the Xcode scheme pre-action during archive.
4. **Verify Signature** — `codesign --verify --deep --strict`, plus checks for the hardened-runtime flag and the Developer ID authority.
5. **Notarize** — `notarytool submit --wait` using the local keychain profile, then `stapler staple` and an `spctl -a -vv` Gatekeeper assessment.
6. **Generate Appcast** — runs Sparkle `generate_appcast`; the changelog HTML is embedded via the basename convention (`Americano.app.zip` ↔ `Americano.app.html`). The EdDSA key comes from the login keychain or `SPARKLE_PRIVATE_KEY_FILE`.
7. **Commit & Tag** — commits `appcast.xml` and `Config.xcconfig` as `[RELEASE] vX.Y.Z`, then atomically pushes `HEAD` + annotated tag `vX.Y.Z`.
8. **Create GitHub Release** — uploads `Americano.app.zip`, `Americano.app.html`, and `appcast.xml` via `gh release create`.
9. **Update Homebrew Tap** — clones `homebrew-tap` with `gh`, updates the Cask with the new version + SHA256, commits (under your own git identity) and pushes. The cask declares `auto_updates true` because updates are delivered by Sparkle.

### 4. Mac App Store channel

```bash
bash Scripts/release-mas.sh
```

The script performs the following automatically:

1. **Preflight** — must run on `main` with a clean working tree; checks the Apple Distribution certificate and the `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_PATH` environment variables.
2. **Archive** — `xcodebuild archive` of the `AmericanoMAS` scheme in Release configuration (App Sandbox entitlements, no Sparkle). The build number is bumped by the scheme pre-action.
3. **Upload** — `xcodebuild -exportArchive` with `method = app-store-connect` and `destination = upload`, signed automatically as Apple Distribution using the API key above. No notarization — App Review covers it.

Then finish manually in App Store Connect: select the uploaded build, fill metadata/screenshots, submit for review.

### 5. Verify

- Check the [Releases](https://github.com/LZhenHong/Americano/releases) page for the new version
- Verify `appcast.xml` on `main` contains the new entry with changelog
- Check `LZhenHong/homebrew-tap` for the updated cask
- On a fresh download: `spctl -a -vv Americano.app` should report `accepted source=Notarized Developer ID`
- App Store Connect → the new build appears under the app's *Builds* (processing takes a few minutes)

## Sparkle Setup

| Item | Value |
|------|-------|
| Framework | Sparkle 2.x via SPM, linked into the `Americano` target only |
| Feed URL | `https://raw.githubusercontent.com/LZhenHong/Americano/main/appcast.xml` |
| Public Key | `SUPublicEDKey` in `Info.plist` |
| Compilation flag | `USE_SPARKLE`, defined in the `Americano` target's build settings (not defined for `AmericanoMAS`) |

## Scripts Reference

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `Scripts/release-local.sh` | Direct channel release: build, notarize, appcast, tag, GitHub Release, Homebrew tap | Manually, on your Mac |
| `Scripts/release-mas.sh` | Mac App Store channel: archive `AmericanoMAS` and upload to App Store Connect | Manually, on your Mac |
| `Scripts/bump-version.sh` | Auto-increment build number | Automatically on every Xcode build (pre-action), including release archives |
| `Scripts/changelog.sh` | Generate AI changelog from git log; writes `Releases/Americano.app.html` so Sparkle auto-embeds it as `<description>` | By `release-local.sh` when `DEEPSEEK_API_KEY` is set |
| `Scripts/gen-appcast.sh` | Generate appcast (Sparkle auto-embeds the HTML next to the ZIP) | By `release-local.sh` |
| `Scripts/homebrew.sh` | Update Homebrew tap cask | By `release-local.sh` |

## Notes

- Do **not** set `BUMP_VERSION` in the scheme environment — semantic version bumping was removed to avoid accidental version increments during release builds.
- `appcast.xml` is tracked in Git on `main`. The release script commits and pushes it automatically.
- The Homebrew tap repository (`LZhenHong/homebrew-tap`) must exist before running a release.
- The direct release script refuses to run if the tag `vVERSION` already exists locally or on `origin`. Bump `VERSION` in `Config.xcconfig` before re-triggering after a successful release.
- MAS uploads require a new `BUILD_NUMBER` per upload within the same `VERSION`; the pre-action bump handles this, so a rejected duplicate-build upload just needs a re-run.
