---
name: xc-export
description: >-
  Export an .ipa or .pkg from an Xcode .xcarchive for development, ad-hoc, TestFlight, App
  Store, enterprise, Developer ID, or Mac App Store. Always confirm distribution method before
  export. Supports iOS, macOS, tvOS, and watchOS archives. Use after xc-archive.
disable-model-invocation: true
---

# xc-export

Export a distributable artifact from an existing **`.xcarchive`** via `xcodebuild -exportArchive`.

Requires a prior **`xc-archive`** run (or an explicit `-ArchivePath`).

---

## Always ask first

Before export, **ask the human** what distribution they need. Map their answer to `-Method`:

| Human says | `-Method` | Output | Typical platform |
|------------|-----------|--------|------------------|
| Development / debug install | `development` | `.ipa` | iOS, tvOS, watchOS |
| Ad-hoc / device list / OTA | `ad-hoc` | `.ipa` | iOS, tvOS, watchOS |
| **TestFlight** | `app-store-connect` | `.ipa` | iOS, tvOS, watchOS |
| **App Store** release | `app-store-connect` | `.ipa` | iOS, tvOS, watchOS |
| Enterprise / in-house | `enterprise` | `.ipa` | iOS |
| **Developer ID** (Mac, notarized) | `developer-id` | `.pkg` | macOS |
| **Mac App Store** | `mac-application` | `.pkg` | macOS |

Also confirm:

- **Archive path** — default `build/{Scheme}.xcarchive`
- **ExportOptions plist** — use bundled `templates/` (copy into repo and set `TEAMID`, bundle IDs,
  profile names) or pass `-ExportOptionsPlist`

**TestFlight vs App Store:** same export method (`app-store-connect`); upload step differs
(`AppStoreRelease@1` with `releaseTrack: TestFlight` vs `Production` in CI).

---

## Command

```powershell
$Export = '.cursor/skills/xc-export/scripts/xc-export.ps1'

# TestFlight / App Store
pwsh $Export -Method app-store-connect -Scheme MyApp

# Ad-hoc
pwsh $Export -Method ad-hoc -ArchivePath build/MyApp.xcarchive

# Development
pwsh $Export -Method development -Scheme MyApp

# Enterprise
pwsh $Export -Method enterprise -Scheme MyApp

# macOS — Developer ID (outside Mac App Store)
pwsh $Export -Method developer-id -Scheme MyMacApp

# macOS — Mac App Store
pwsh $Export -Method mac-application -Scheme MyMacApp
```

Output: `build/export/` (`.ipa` for iOS/tvOS/watchOS, `.pkg` for macOS when applicable).

---

## ExportOptions templates

`templates/` ships one plist per method. Copy into the repo (or Azure DevOps Secure Files),
replace placeholders, and pass `-ExportOptionsPlist` if not using defaults:

| File | Method |
|------|--------|
| `ExportOptions.development.plist` | `development` |
| `ExportOptions.adhoc.plist` | `ad-hoc` |
| `ExportOptions.appstore.plist` | `app-store-connect` (TestFlight + App Store) |
| `ExportOptions.enterprise.plist` | `enterprise` |
| `ExportOptions.developer-id.plist` | `developer-id` |
| `ExportOptions.mac-application.plist` | `mac-application` |

Set `teamID`, bundle-id → profile-name mappings, and `signingStyle` (`automatic` when profiles
live in the `.xcodeproj`; `manual` for CI). See `rules/ios-signing.mdc`.

---

## Workflow

```text
xc-archive (done) → Ask distribution method → pick template → xc-export → upload / publish artifact
```

**CI (Azure DevOps):** after export, `AppStoreRelease@1` for TestFlight when
`-Method app-store-connect`; publish IPA artifact for ad-hoc/enterprise. See
`skills/ios-azure-pipelines`.

---

## Constraints

- Export **method must match** the provisioning profile used during archive.
- Never embed certificates, profiles, or API keys in templates committed with real secrets.
- If export fails on profile mismatch, fix signing in `.xcodeproj` or re-archive with the
  correct profile — do not guess a different `-Method`.
