# HDrezka Constitution

## Core Principles

### I. Native Apple platforms first
Ship a reliable unofficial HDrezka client for macOS 15+, iPadOS 18+, and tvOS using Swift and SwiftUI. Prefer platform APIs (AVFoundation/AVKit, SwiftUI navigation) over web wrappers for browsing and playback.

### II. Shared core, platform shells
Keep domain models, networking, and shared UI logic in `HDrezka/Shared` (and shared targets). Platform-specific presentation lives under `macOS` / `iOS` / tvOS trees (`HDrezkaTV`, `RezkaTV`). Do not duplicate business logic across targets without a clear reason.

### III. Spec-driven changes (NON-NEGOTIABLE for pipeline work)
Feature work through the SDLC uses Spec Kit artifacts (`spec.md` → `plan.md` → `tasks.md`) as canonical. Pipeline docs (REQ/SDD/TDD/TEST) supplement them; they must not contradict Spec Kit.

### IV. Code search before create
Before adding files, modules, or helpers, search the existing codebase (codesearch / MCP) and produce a Dedupe Ticket (`reuse | extend | new`). Prefer extending Shared layers over new parallel implementations.

### V. Security for auth and local storage
Account authentication, cookies/session tokens, and any credential-like Defaults/Keychain data are sensitive. Prefer Keychain for secrets; never log tokens; security-reviewer gates apply when auth/storage changes.

### VI. Simplicity and focus
YAGNI: solve the user’s browse / search / bookmarks / play / download flows first. Avoid speculative abstractions and third-party SDKs when Apple frameworks suffice.

## Stack constraints

- Language: Swift
- UI: SwiftUI
- Platforms: macOS 15+, iPadOS 18+, tvOS
- Project: Xcode (`HDrezka.xcodeproj`)
- Pack: `ios-native` pipeline overlays (lint / build / test scripts)
- Code search: local `codesearch` index (`.codesearch.db`)

## Development workflow

1. Adapt / constitution stay current with `PROJECT.md`.
2. Feature lane: `/speckit-specify` → clarify → `/speckit-plan` → `/speckit-tasks` → implement → test gate.
3. Build/test/format commands live in `pipeline.manifest.json` (SwiftLint + xcode-build / swift-test).
4. Human confirmation at pack recommendation and before shipping destructive ops.

## Governance

- This constitution supersedes ad-hoc agent style choices when they conflict.
- Amendments: update this file and `PROJECT.md` together; note date below.
- PRs/reviews for pipeline features verify Spec Kit artifacts and Dedupe Ticket discipline.

**Version**: 1.0.0 | **Ratified**: 2026-07-15 | **Last Amended**: 2026-07-15
