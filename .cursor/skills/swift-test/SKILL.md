---
name: swift-test
description: >-
  Run Swift Testing (unit/integration) and XCUITest (UI) via xcodebuild, producing JUnit,
  Cobertura coverage, and TestResults/azure-devops-results.json for Azure DevOps. Use at
  Phase 7.5 (unit/integration) and 7.6 (UI) after writing tests.
disable-model-invocation: true
---

# swift-test

Deterministic **test + coverage** runner for native Apple targets. Uses **Swift Testing**
for unit/integration tests and **XCUITest** for UI automation (Swift Testing does not
support UI automation or `XCTMetric`).

## Test framework policy (2026)

- **New unit/integration tests: Swift Testing** (`@Test`, `#expect`, `#require`,
  parameterized tests, `@Suite`). Default for new projects in Xcode 16+/26.
- **UI tests: XCUITest** (`XCUIApplication`). Keep these on XCTest.
- Swift Testing and XCTest **coexist** in the same target — migrate legacy XCTests
  incrementally (port a file when you touch it). Don't mix `#expect` and `XCTAssert` in
  the same test.

```swift
import Testing
@testable import FeatureHome

@Suite struct CounterModelTests {
    @Test func incrementsByOne() {
        let model = CounterModel()
        model.increment()
        #expect(model.count == 1)
    }

    @Test(arguments: [0, 5, 99])
    func startsAtGivenValue(_ start: Int) {
        #expect(CounterModel(count: start).count == start)
    }
}
```

## When to run

| Step | Action |
|------|--------|
| **7.4** | Write code |
| **swift-format** | Format |
| **7.5** | **This skill** — unit/integration (Swift Testing) + coverage |
| **7.6** | **This skill** (UI scheme/filter) — XCUITest flows |
| **7.7** | Polish |
| **7.8** | Dev gate |

## Commands

From repo root (PowerShell Core):

```powershell
$Tests = '.cursor/skills/swift-test/scripts/swift-test.ps1'

# Default — auto-detect workspace/scheme, iOS Simulator, with coverage
pwsh $Tests

# Explicit scheme + destination
pwsh $Tests -Scheme MyApp -Destination 'platform=iOS Simulator,name=iPhone 16'

# Filter to a suite/target (xcodebuild -only-testing)
pwsh $Tests -Filter MyAppTests/CounterModelTests

# Faster local loop (no coverage)
pwsh $Tests -NoCoverage

# Standalone Swift package (no .xcodeproj) → falls back to `swift test`
pwsh $Tests
```

Auto-detects the `.xcworkspace`/`.xcodeproj` and first scheme; override with
`-Workspace` / `-Project` / `-Scheme`.

## Tooling (self-hosted Mac / dev)

```bash
brew install xcbeautify        # JUnit report from xcodebuild output (recommended)
brew install xcresultparser    # optional: xcresult → Cobertura coverage
```

Without `xcbeautify`, tests still run but no `junit.xml` is produced. Without a Cobertura
converter, line-coverage % is still captured in the summary JSON.

## Outputs (Azure DevOps)

All paths repo-relative — stable for CI publish tasks.

| File | Purpose |
|------|---------|
| `TestResults/junit.xml` | JUnit → `PublishTestResults@2` (`testResultsFormat: JUnit`) |
| `TestResults/coverage/cobertura.xml` | Cobertura → `PublishCodeCoverageResults@2` |
| `TestResults/Test.xcresult` | Raw result bundle (artifact / deep dives) |
| `TestResults/azure-devops-results.json` | Machine-readable summary for agents / gates |

### `azure-devops-results.json` shape

```json
{
  "schemaVersion": "1",
  "passed": true,
  "exitCode": 0,
  "tests": { "total": 128, "failed": 0 },
  "azureDevOps": {
    "publishTestResults": {
      "testResultsFormat": "JUnit",
      "testResultsFiles": "TestResults/junit.xml"
    },
    "publishCodeCoverageResults": {
      "codeCoverageTool": "Cobertura",
      "summaryFileLocation": "TestResults/coverage/cobertura.xml"
    }
  },
  "coverage": { "lineCoveragePercent": 84.7, "linesValid": 2000, "linesCovered": 1694 }
}
```

### Azure Pipelines YAML

```yaml
- pwsh: .cursor/skills/swift-test/scripts/swift-test.ps1 -Scheme $(scheme) -Destination '$(destination)'
  displayName: Unit/integration tests + coverage

- task: PublishTestResults@2
  condition: always()
  inputs:
    testResultsFormat: JUnit
    testResultsFiles: TestResults/junit.xml
    mergeTestResults: true

- task: PublishCodeCoverageResults@2
  condition: succeededOrFailed()
  inputs:
    codeCoverageTool: Cobertura
    summaryFileLocation: $(System.DefaultWorkingDirectory)/TestResults/coverage/cobertura.xml
```

## Checkpoint

```powershell
pwsh $Tests 2>&1 | pwsh .cursor/skills/checkpoint/scripts/save-artifact.ps1 `
  -Session <session> -ArtifactRel gates/swift-tests.log -Mode --stdin
```

Cite `TestResults/azure-devops-results.json` (paths + coverage %) in chat — never paste the
full `.xcresult`.

## Constraints

- Run after test code is written (7.5/7.6) — not a substitute for writing tests.
- Keep UI tests on XCUITest; keep unit/integration on Swift Testing for new code.
- On failure, loop to 7.4/7.5 until green.
