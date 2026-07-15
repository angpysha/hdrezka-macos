# swift-test.ps1 — run Swift Testing / XCTest unit+integration tests via xcodebuild,
# produce JUnit (PublishTestResults@2), Cobertura coverage (PublishCodeCoverageResults@2),
# and a machine-readable TestResults/azure-devops-results.json summary.
#
# Auto-detects workspace/project and scheme when not supplied. macOS + Xcode required.
#
# Usage (from repo root, PowerShell Core):
#   pwsh .cursor/skills/swift-test/scripts/swift-test.ps1
#   pwsh .cursor/skills/swift-test/scripts/swift-test.ps1 -Scheme MyApp -Destination 'platform=iOS Simulator,name=iPhone 16'
#   pwsh .cursor/skills/swift-test/scripts/swift-test.ps1 -Filter MyAppTests/CounterModelTests -NoCoverage
param(
    [string]$Workspace = '',
    [string]$Project = '',
    [string]$Scheme = '',
    [string]$Destination = 'platform=iOS Simulator,name=iPhone 16',
    [string]$Configuration = 'Debug',
    [string]$ResultsDir = 'TestResults',
    [string]$Filter = '',
    [switch]$NoCoverage
)

$ErrorActionPreference = 'Stop'

function Test-Command([string]$Name) { return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

if (-not (Test-Command 'xcodebuild')) {
    Write-Error 'xcodebuild not found. This skill requires macOS with Xcode installed.'
    exit 1
}

# --- Resolve container (workspace preferred, else project) ----------------------------
if (-not $Workspace -and -not $Project) {
    $ws = Get-ChildItem -Path . -Filter *.xcworkspace -Depth 2 -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch 'project\.xcworkspace$' } | Select-Object -First 1
    if ($ws) {
        $Workspace = $ws.FullName
    }
    else {
        $proj = Get-ChildItem -Path . -Filter *.xcodeproj -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($proj) { $Project = $proj.FullName }
    }
}

$containerArgs = @()
if ($Workspace) { $containerArgs = @('-workspace', $Workspace) }
elseif ($Project) { $containerArgs = @('-project', $Project) }
else {
    # Standalone Swift package: fall back to `swift test`.
    Write-Host '>> no .xcworkspace/.xcodeproj found — running `swift test`'
    & swift test --enable-code-coverage
    exit $LASTEXITCODE
}

# --- Resolve scheme -------------------------------------------------------------------
if (-not $Scheme) {
    $listJson = & xcodebuild @containerArgs -list -json 2>$null | Out-String
    try {
        $info = $listJson | ConvertFrom-Json
        $schemes = if ($info.workspace) { $info.workspace.schemes } else { $info.project.schemes }
        if ($schemes -and $schemes.Count -gt 0) { $Scheme = $schemes[0] }
    }
    catch { }
    if (-not $Scheme) {
        Write-Error 'Could not auto-detect a scheme. Pass -Scheme explicitly.'
        exit 1
    }
    Write-Host ">> auto-detected scheme: $Scheme"
}

# --- Prepare output dirs --------------------------------------------------------------
$null = New-Item -ItemType Directory -Force -Path $ResultsDir
$coverageDir = Join-Path $ResultsDir 'coverage'
$null = New-Item -ItemType Directory -Force -Path $coverageDir
$xcresult = Join-Path $ResultsDir 'Test.xcresult'
if (Test-Path $xcresult) { Remove-Item -Recurse -Force $xcresult }

# --- Build xcodebuild test args -------------------------------------------------------
$testArgs = @() + $containerArgs + @(
    '-scheme', $Scheme,
    '-configuration', $Configuration,
    '-destination', $Destination,
    '-resultBundlePath', $xcresult,
    '-skipPackagePluginValidation'
)
if (-not $NoCoverage) { $testArgs += @('-enableCodeCoverage', 'YES') }
if ($Filter) { $testArgs += @('-only-testing', $Filter) }

Write-Host ">> xcodebuild test -scheme $Scheme -destination '$Destination'"

$junit = Join-Path $ResultsDir 'junit.xml'
$exitCode = 0

if (Test-Command 'xcbeautify') {
    # xcbeautify emits JUnit; preserve xcodebuild's real exit code via PIPESTATUS-style check.
    & xcodebuild test @testArgs | & xcbeautify --report junit --report-path $ResultsDir --junit-report-filename junit.xml
    $exitCode = $LASTEXITCODE
    # When piped, $LASTEXITCODE is xcbeautify's; re-derive pass/fail from the result bundle below.
}
else {
    Write-Warning 'xcbeautify not found — running raw xcodebuild (no JUnit report). Install via `brew install xcbeautify`.'
    & xcodebuild test @testArgs
    $exitCode = $LASTEXITCODE
}

# --- Parse results from the xcresult bundle ------------------------------------------
$passed = $true
$total = 0; $failures = 0
$lineCoveragePct = $null; $linesValid = $null; $linesCovered = $null

if (Test-Path $xcresult) {
    try {
        $summary = & xcrun xcresulttool get test-results summary --path $xcresult 2>$null | ConvertFrom-Json
        if ($null -ne $summary) {
            $passed = ($summary.result -eq 'Passed')
            if ($null -ne $summary.totalTestCount) { $total = [int]$summary.totalTestCount }
            if ($null -ne $summary.failedTests) { $failures = [int]$summary.failedTests }
        }
    }
    catch {
        # Older Xcode: fall back to legacy flag.
        try {
            $legacy = & xcrun xcresulttool get --legacy --format json --path $xcresult 2>$null | ConvertFrom-Json
            $passed = (& { try { $legacy.metrics.testsFailedCount._value } catch { $null } } ) -in @($null, 0)
        }
        catch { }
    }

    if (-not $NoCoverage) {
        try {
            $cov = & xcrun xccov view --report --json $xcresult 2>$null | ConvertFrom-Json
            if ($null -ne $cov.lineCoverage) {
                $lineCoveragePct = [math]::Round([double]$cov.lineCoverage * 100, 2)
                $linesValid = [int]$cov.executableLines
                $linesCovered = [int]$cov.coveredLines
            }
        }
        catch { Write-Warning "Coverage extraction failed: $($_.Exception.Message)" }

        # Optional Cobertura conversion if a converter is available (xcresultparser / xccov2cobertura).
        $cobertura = Join-Path $coverageDir 'cobertura.xml'
        if (Test-Command 'xcresultparser') {
            & xcresultparser -o cobertura $xcresult 2>$null | Out-File -Encoding utf8 $cobertura
        }
        elseif (Test-Command 'xccov2cobertura') {
            & xcov2cobertura --xcresult $xcresult --output $cobertura 2>$null
        }
        else {
            Write-Warning 'No Cobertura converter found (xcresultparser / xccov2cobertura). Coverage % captured in summary JSON only.'
        }
    }
}
else {
    # No bundle => infer from exit code.
    $passed = ($exitCode -eq 0)
}

# --- Emit Azure DevOps summary JSON ---------------------------------------------------
$result = [ordered]@{
    schemaVersion = '1'
    passed        = $passed
    exitCode      = if ($passed) { 0 } else { 1 }
    tests         = [ordered]@{ total = $total; failed = $failures }
    azureDevOps   = [ordered]@{
        publishTestResults        = [ordered]@{
            testResultsFormat = 'JUnit'
            testResultsFiles  = (Join-Path $ResultsDir 'junit.xml')
        }
        publishCodeCoverageResults = [ordered]@{
            codeCoverageTool    = 'Cobertura'
            summaryFileLocation = (Join-Path $coverageDir 'cobertura.xml')
        }
    }
    coverage      = [ordered]@{
        lineCoveragePercent = $lineCoveragePct
        linesValid          = $linesValid
        linesCovered        = $linesCovered
    }
    xcresult      = $xcresult
}

$summaryPath = Join-Path $ResultsDir 'azure-devops-results.json'
$result | ConvertTo-Json -Depth 6 | Out-File -Encoding utf8 $summaryPath
Write-Host "OK summary: $summaryPath (passed=$passed, tests=$total, failed=$failures, lineCoverage=$lineCoveragePct%)"

if (-not $passed) {
    Write-Error 'Tests failed.'
    exit 1
}
exit 0
