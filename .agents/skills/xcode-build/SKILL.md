---
name: xcode-build
description: >-
  Fast compile-only build gate for Apple platforms (iOS, macOS, tvOS, watchOS) via xcodebuild
  without signing. Use xc-archive to create .xcarchive and xc-export for IPA/TestFlight/ad-hoc.
  Pairs with ios-azure-pipelines for CI.
disable-model-invocation: true
---

# xcode-build

**Compile-only** `xcodebuild` gate — no code signing. Use for PR / build verification.

| Skill | Purpose |
|-------|---------|
| **`xcode-build`** (this) | `build` — fast compile, `CODE_SIGNING_ALLOWED=NO` |
| **`xc-archive`** | signed `.xcarchive` (default: provisioning from `.xcodeproj`) |
| **`xc-export`** | `.ipa` / `.pkg` for development, ad-hoc, TestFlight, App Store, etc. |

## Command

```powershell
$Build = '.cursor/skills/xcode-build/scripts/xcode-build.ps1'

pwsh $Build
pwsh $Build -Scheme MyApp -Platform iOS
pwsh $Build -Scheme MyMacApp -Platform macOS
pwsh $Build -Scheme MyTVApp -Platform tvOS
```

Platforms: `iOS` | `macOS` | `tvOS` | `watchOS` | `visionOS`

## Release workflow

1. **`xc-archive`** — ask platform, scheme, signing style, distribution intent
2. **`xc-export`** — ask distribution method (development, ad-hoc, TestFlight, …)

Do not use `xcode-build` for release artifacts.

## Checkpoint

```powershell
pwsh $Build 2>&1 | pwsh .cursor/skills/checkpoint/scripts/save-artifact.ps1 `
  -Session <session> -ArtifactRel gates/xcode-build.log -Mode --stdin
```

## Legacy

`-Action archive` and `-Action export` delegate to **`xc-archive`** / **`xc-export`** with
Manual signing (CI). Prefer calling those skills directly.
