---
name: xc-archive
description: >-
  Create a signed Xcode .xcarchive for iOS, macOS, tvOS, or watchOS. Default signing uses
  provisioning from the .xcodeproj (Automatic). Always confirm platform and scheme before
  archiving. Use before xc-export, TestFlight, or local release builds.
disable-model-invocation: true
---

# xc-archive

Create a **signed `.xcarchive`** with `xcodebuild archive`. Pair with **`xc-export`** to
produce an `.ipa` / `.pkg` for distribution.

**Default:** signing and provisioning come from the **`.xcodeproj` / `.pbxproj`**
(`CODE_SIGN_STYLE=Automatic`, `-allowProvisioningUpdates`). Do not override profiles unless
the human asks for **Manual** signing (CI / explicit certificate).

---

## Always ask first

Before running archive, **ask the human** (use `AskQuestion` when available). Do not guess.

### 1. Platform

| Option | `-Platform` | Archive destination |
|--------|-------------|---------------------|
| iPhone / iPad | `iOS` | `generic/platform=iOS` |
| Mac | `macOS` | `generic/platform=macOS` |
| Apple TV | `tvOS` | `generic/platform=tvOS` |
| Apple Watch | `watchOS` | `generic/platform=watchOS` |
| Apple Vision | `visionOS` | `generic/platform=visionOS` |

**watchOS note:** many apps archive via the **iOS container scheme** (Watch app embedded).
Confirm which scheme targets the deliverable.

### 2. Scheme & configuration

- **Scheme** — app, extension, or multiplatform target? List with
  `xcodebuild -list` if unclear.
- **Configuration** — usually `Release` for distribution; `Debug` only when asked.

### 3. Signing style

| Style | When | Script flag |
|-------|------|-------------|
| **Automatic** (default) | Local dev; profiles in Xcode / pbxproj | `-SigningStyle Automatic` |
| **Manual** | CI with Secure Files / explicit cert+profile | `-SigningStyle Manual` + team/identity/profile |

### 4. Distribution intent (for later export)

Ask what the archive is **for** — you do not export in this step, but the answer guides
profile/capability checks:

- **Development** — local install / debugger
- **Ad-hoc** — registered devices, OTA
- **TestFlight** — App Store Connect beta
- **App Store** — production release (same export method as TestFlight)
- **Enterprise** — in-house (requires Enterprise program)
- **Developer ID** — macOS outside Mac App Store
- **Mac App Store** — macOS App Store

If provisioning in the project does not match the intent, stop and fix signing in Xcode or
`pbxproj` before archiving.

---

## Command

From repo root:

```powershell
$Archive = '.cursor/skills/xc-archive/scripts/xc-archive.ps1'

# Default — Automatic signing from .xcodeproj
pwsh $Archive -Scheme MyApp -Platform iOS

# macOS
pwsh $Archive -Scheme MyMacApp -Platform macOS

# tvOS / watchOS
pwsh $Archive -Scheme MyTVApp -Platform tvOS
pwsh $Archive -Scheme MyWatchApp -Platform watchOS

# CI — Manual signing (Azure DevOps InstallApple* tasks export env vars)
pwsh $Archive -Scheme MyApp -Platform iOS -SigningStyle Manual `
  -TeamId $env:APPLE_TEAM_ID `
  -SigningIdentity $env:APPLE_CERTIFICATE_SIGNING_IDENTITY `
  -ProvisioningProfileUuid $env:APPLE_PROV_PROFILE_UUID
```

Output: `build/{Scheme}.xcarchive` (override with `-OutputDir` / `-ArchivePath`).

---

## Workflow

```text
Ask platform → Ask scheme → Ask signing style → Ask distribution intent (sanity-check profiles)
  → xc-archive → hand off to xc-export
```

---

## Constraints

- **macOS + Xcode required** — `xcodebuild` only runs on Mac.
- Never commit certificates, `.p12`, `.mobileprovision`, or API keys.
- For **export** (IPA/TestFlight/ad-hoc), use **`xc-export`** — not this skill.
- Build gate (compile only, no signing): **`xcode-build`** `-Action build`.
