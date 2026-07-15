---
name: swift-lint
description: >-
  Lint and format Swift with SwiftLint (rules) and swift-format (Apple's formatter).
  Use at step 7.7 polish and as the pre-commit/build gate. Fails on violations so CI stays
  green only when code is clean.
disable-model-invocation: true
---

# swift-lint

Deterministic **lint + format** for Swift, combining:

- **SwiftLint** — style/convention rule enforcement (config: `.swiftlint.yml`).
- **swift-format** — Apple's official formatter (config: `.swift-format.json`).

## When to run

| Step | Action |
|------|--------|
| **7.4** | Write code |
| **swift-format** | `-Mode format` — apply formatting |
| **7.5 / 7.6** | Tests |
| **7.7** | `-Mode lint` — must be **0 violations** |
| **7.8** | Dev gate |

## Commands

From repo root (PowerShell Core):

```powershell
$Lint = '.cursor/skills/swift-lint/scripts/swift-lint.ps1'

pwsh $Lint -Mode format        # swift-format in place + SwiftLint --fix (autocorrect)
pwsh $Lint -Mode lint          # check only; non-zero exit on any violation (CI gate)
pwsh $Lint -Mode check         # swift-format --lint (diff-only) + SwiftLint strict, no writes
pwsh $Lint -Mode lint -Paths Sources Tests
```

## Tooling install (one-time, self-hosted Mac / dev)

```bash
brew install swiftlint        # SwiftLint
# swift-format ships with the Swift 6 toolchain: `swift format ...`
# (or `brew install swift-format` for a standalone binary)
```

The script prefers `swift format` (toolchain) and falls back to a standalone
`swift-format` binary; SwiftLint is required for `lint`/`check` modes.

## Config

- `.swiftlint.yml` and `.swift-format.json` templates are in this skill's `templates/`.
  Copy them to the repo root on first setup:

```powershell
Copy-Item .cursor/skills/swift-lint/templates/.swiftlint.yml .
Copy-Item .cursor/skills/swift-lint/templates/.swift-format.json .
```

## Azure Pipelines

```yaml
- pwsh: .cursor/skills/swift-lint/scripts/swift-lint.ps1 -Mode check
  displayName: Swift lint + format check
```

## Constraints

- `-Mode lint`/`check` must exit non-zero on any violation — never weaken the gate to pass.
- Format (`swift-format`) and lint (`SwiftLint`) are complementary: format handles
  whitespace/layout; SwiftLint enforces conventions. Run both.
- Keep the two configs consistent (e.g. line length) so they don't fight.
