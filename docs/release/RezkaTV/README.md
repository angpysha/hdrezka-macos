# RezkaTV Ad Hoc export

Build / archive / export settings for Apple TV ad-hoc IPA.

## Paths

| Item | Path |
|------|------|
| Export options | `docs/release/RezkaTV/ExportOptions.plist` |
| Ad Hoc profile | `/Users/andrii/Downloads/RezkaTv_AdHoc_2026.mobileprovision` |
| Profile name | `RezkaTv AdHoc 2026` |
| Bundle ID | `net.petrovskyi.RezkaTV` |
| Team | `RFVKD37M39` |

Install the profile once (UUID filename required):

```bash
PROFILE="/Users/andrii/Downloads/RezkaTv_AdHoc_2026.mobileprovision"
UUID=$(security cms -D -i "$PROFILE" | plutil -extract UUID raw -o - -)
mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
cp "$PROFILE" "$HOME/Library/MobileDevice/Provisioning Profiles/${UUID}.mobileprovision"
```

## Bump build number

In `HDrezka.xcodeproj` → target **RezkaTV** → `CURRENT_PROJECT_VERSION` (Debug + Release).

## Archive + export

Do **not** pass a global `PROVISIONING_PROFILE_SPECIFIER` on the command line (it breaks SPM resource bundles). Rely on the target’s `[sdk=appletvos*]` settings.

```bash
# From repo root — bump CURRENT_PROJECT_VERSION first
rm -rf build/RezkaTV.xcarchive build/export

xcodebuild archive \
  -project HDrezka.xcodeproj \
  -scheme RezkaTV \
  -configuration Release \
  -destination 'generic/platform=tvOS' \
  -archivePath build/RezkaTV.xcarchive \
  VALIDATE_PRODUCT=NO

pwsh .cursor/skills/xc-export/scripts/xc-export.ps1 \
  -ArchivePath build/RezkaTV.xcarchive \
  -Method ad-hoc \
  -ExportOptionsPlist docs/release/RezkaTV/ExportOptions.plist \
  -ExportDir build/export
```

`VALIDATE_PRODUCT=NO` skips App Store icon validation while brand assets are not yet fixed.

IPA output: `build/export/RezkaTV.ipa`

`ExportOptions.plist` uses method `release-testing` (ad-hoc) and pins certificate SHA `BD085C2141CAA8B738089CF246C5D16D9D4BA52A`.
