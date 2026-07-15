---
name: ios-azure-pipelines
description: >-
  Azure DevOps CI/CD for native Apple apps on a self-hosted Mac — lint, test+coverage,
  archive with native Apple signing (Secure Files), and distribute to TestFlight/App Store,
  Ad-hoc, or Enterprise. Use when setting up or editing the pipeline. No fastlane.
disable-model-invocation: true
---

# ios-azure-pipelines

Azure DevOps Pipelines for native Apple apps, **self-hosted Mac** agent, **native Apple
signing** (no fastlane). Templates live in `templates/`:

| File | Role |
|------|------|
| `azure-pipelines.yml` | Root pipeline: Validate → Test → Release stages |
| `stage-build-test.yml` | Reusable job: lint + compile, or test + publish results |
| `stage-release.yml` | Reusable job: install signing, archive, export, distribute |

Copy them to the repo (e.g. `azure-pipelines/`) and point the pipeline at the root file.

## Pipeline shape

```
push / PR ──► Validate (lint + swift-format + compile, no signing)
          └─► Test     (Swift Testing + coverage → PublishTestResults/CodeCoverage)
main / v* ──► Release  (InstallAppleCertificate → archive → exportArchive → distribute)
```

## One-time setup

1. **Self-hosted Mac agent** in a pool (default `macOS-self-hosted`) with: Xcode, PowerShell
   Core (`pwsh`), `xcbeautify`, `swiftlint`, and the Swift toolchain `swift format`.
2. **Apple App Store** Azure DevOps extension installed (provides `AppStoreRelease@1`).
3. **Secure Files** (Pipelines ▸ Library ▸ Secure files): upload the distribution `.p12`
   and the `.mobileprovision`. Reference them by name in `azure-pipelines.yml`.
4. **Variable group `ios-signing`** (ideally linked to Azure Key Vault):

   | Variable | Meaning |
   |----------|---------|
   | `APPLE_TEAM_ID` | 10-char Apple Team ID |
   | `P12_PASSWORD` | password for the distribution `.p12` (secret) |
   | `ASC_KEY_ID` | App Store Connect API Key ID |
   | `ASC_ISSUER_ID` | App Store Connect Issuer ID |
   | `ASC_KEY_BASE64` | base64 of the `AuthKey_*.p8` contents (secret) |
   | `APP_SPECIFIC_ID` | App Store "Apple ID" number (avoids 2FA on upload) |

## Signing flow (native, no fastlane)

`InstallAppleCertificate@2` + `InstallAppleProvisioningProfile@1` import the `.p12` and
profile from Secure Files into a **temporary keychain** and export
`$(APPLE_CERTIFICATE_SIGNING_IDENTITY)` and `$(APPLE_PROV_PROFILE_UUID)`. Skills
**`xc-archive`** (Manual signing) and **`xc-export`** consume those in CI. Local dev uses
Automatic signing from `.xcodeproj`. See `rules/ios-signing.mdc`.

## Distribution

Ask / parameterize **`distribution`** before release. Map to **`xc-export -Method`**:

| `distribution` param | Export method | Outcome | Platforms |
|----------------------|---------------|---------|-----------|
| `development` | `development` | `.ipa` artifact | iOS, tvOS, watchOS |
| `app-store-connect` | `app-store-connect` | **TestFlight** via `AppStoreRelease@1` | iOS, tvOS, watchOS, Mac App Store |
| `ad-hoc` | `ad-hoc` | `.ipa` for registered devices | iOS, tvOS, watchOS |
| `enterprise` | `enterprise` | in-house `.ipa` | iOS |
| `developer-id` | `developer-id` | `.pkg` (notarized Mac) | macOS |
| `mac-application` | `mac-application` | Mac App Store `.pkg` | macOS |

Set **`platform`** on `stage-release.yml` (`iOS` | `macOS` | `tvOS` | `watchOS` | `visionOS`).

Choose at queue time (pipeline parameter) or per-branch.

## Self-hosted Mac notes

- Keep a **dedicated keychain** for the agent; the Install* tasks default to a temp
  keychain and clean up (`deleteCert`/`removeProfile: true`).
- Pre-install tools on the agent image; don't `brew install` mid-pipeline.
- Cache `~/Library/Developer/Xcode/DerivedData` and SPM (`Package.resolved` committed) for
  faster builds.

## Microsoft-hosted alternative

If you ever move to Microsoft-hosted agents (`vmImage: macOS-latest`), the same templates
work — pre-install steps for `xcbeautify`/`swiftlint` are needed each run, and signing
assets must be re-imported every build (already the case here).

## Constraints

- **CI:** Manual signing for release (`xc-archive -SigningStyle Manual`); secrets via Secure
  Files + variable group, never the repo. **Local:** Automatic signing from `.xcodeproj`.
- App Store Connect **API key** auth (not Apple ID + password).
- Gate the Release stage on `main`/tags; never sign/upload from PR builds.
