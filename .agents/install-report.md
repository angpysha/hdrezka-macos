# Adapt install report — HDrezka

Generated during `.agents adapt` (2026-07-15).

## Detection

| Signal | Source | Result |
|--------|--------|--------|
| Languages | codesearch doctor/stats | Swift dominant (326), JSON (53), Markdown (20); 397 files / 1685 chunks |
| Project layout | codesearch + filesystem | `HDrezka/` (Shared/iOS/macOS), `HDrezkaTV/`, `RezkaTV/`, `HDrezka.xcodeproj` |
| UI / player | codesearch semantic | SwiftUI apps; AVPlayer / custom `PlayerView` |
| Brief | PROJECT.md | Swift, SwiftUI, macOS 15+ / iPadOS 18+ / tvOS, Xcode |
| Graphify | CLI | **Skipped** — no LLM API key (`GEMINI_API_KEY` / etc.) |
| MCP codebase-search | session | **Not attached**; project MCP uses rust `codesearch mcp` |
| Auth | codesearch | Sign-in / `Defaults` login state → enable security-reviewer |
| CI / PR | filesystem | None detected → `pr.type: manual` |
| Tracker | PROJECT.md / manifest | beads (`task`) |
| CocoaPods | filesystem | No Podfile → feature off |

## Recommended pack

| Pack | Score | Confidence |
|------|-------|------------|
| **ios-native** | 0.95 | **high** |

Add-ons: none (no postgres-ef / helm-k8s / cocoapods-migration signals).

## Recommended agents

coordinator, ba-analyst, architect, team-lead, developer, tester, devops, security-reviewer, tech-writer

## Build / test / format (from ios-native defaults)

- **build:** swift-lint + xcode-build
- **test:** swift-test → `TestResults/`
- **format:** swift-lint format

## Spec Kit

`spec_kit.enabled: true`, integration `cursor`. After apply, run:

```bash
specify init . --integration cursor
```

Then seed constitution from `PROJECT.md` via `/speckit.constitution`.

## Apply / verify

| Step | Result |
|------|--------|
| Human confirm | approved |
| `agentic-tool apply` | OK — pack `ios-native`, status `ready` |
| Spec Kit | `specify init . --integration cursor-agent --force` |
| Constitution | seeded from `PROJECT.md` → `.specify/memory/constitution.md` |
| Manifest restore | `code_search` + `spec_kit` + `project.brief` (apply had dropped them) |
| `agentic-tool sync` + `verify` | run after closeout |

Ready for: `Run SDLC for: {feature}`
