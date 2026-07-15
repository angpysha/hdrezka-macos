# swift-lint.ps1 — SwiftLint + swift-format runner (lint / format / check).
# Modes:
#   format : swift-format in place + SwiftLint autocorrect (--fix)        [writes files]
#   lint   : SwiftLint (strict) — CI gate, non-zero on any violation       [read-only]
#   check  : swift-format --lint + SwiftLint strict                        [read-only]
# Usage (from repo root, PowerShell Core):
#   pwsh .cursor/skills/swift-lint/scripts/swift-lint.ps1 -Mode lint
#   pwsh .cursor/skills/swift-lint/scripts/swift-lint.ps1 -Mode format -Paths Sources Tests
param(
    [ValidateSet('format', 'lint', 'check')]
    [string]$Mode = 'lint',
    [string[]]$Paths = @('.'),
    [string]$SwiftLintConfig = '.swiftlint.yml',
    [string]$SwiftFormatConfig = '.swift-format.json'
)

$ErrorActionPreference = 'Stop'

function Test-Command([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# Resolve swift-format invocation: prefer toolchain `swift format`, fall back to standalone
# binary. Returns the command plus the leading args ("prefix") that select the tool.
function Get-SwiftFormat {
    if (Test-Command 'swift') {
        & swift format --version *> $null   # exits 0 when the subcommand exists
        if ($LASTEXITCODE -eq 0) { return @{ Cmd = 'swift'; Prefix = @('format') } }
    }
    if (Test-Command 'swift-format') { return @{ Cmd = 'swift-format'; Prefix = @() } }
    return $null
}

# Run swift-format in the given sub-mode ('format' or 'lint'), splatting a real array.
function Invoke-SwiftFormat {
    param([hashtable]$Tool, [string]$SubMode, [string[]]$ExtraArgs)
    $sfArgs = @($Tool.Prefix) + @($SubMode) + $ExtraArgs
    & $Tool.Cmd @sfArgs
    return $LASTEXITCODE
}

$hasSwiftLint = Test-Command 'swiftlint'
$swiftFormat = Get-SwiftFormat
$failed = $false

$fmtConfigArgs = @()
if (Test-Path $SwiftFormatConfig) { $fmtConfigArgs = @('--configuration', $SwiftFormatConfig) }

$lintConfigArgs = @()
if (Test-Path $SwiftLintConfig) { $lintConfigArgs = @('--config', $SwiftLintConfig) }

Write-Host "=== swift-lint (mode: $Mode) ==="

switch ($Mode) {
    'format' {
        if ($swiftFormat) {
            Write-Host '>> swift-format (in place)'
            $code = Invoke-SwiftFormat -Tool $swiftFormat -SubMode 'format' `
                -ExtraArgs (@('--in-place', '--recursive') + $fmtConfigArgs + $Paths)
            if ($code -ne 0) { $failed = $true }
        }
        else {
            Write-Warning 'swift-format not found — skipping format. Install via Swift toolchain or `brew install swift-format`.'
        }
        if ($hasSwiftLint) {
            Write-Host '>> swiftlint --fix'
            & swiftlint --fix @lintConfigArgs
            # --fix returns non-zero if remaining violations; report but do not hard-fail format mode
        }
        else {
            Write-Warning 'swiftlint not found — skipping autocorrect. Install via `brew install swiftlint`.'
        }
    }
    'check' {
        if ($swiftFormat) {
            Write-Host '>> swift-format --lint (diff-only)'
            $code = Invoke-SwiftFormat -Tool $swiftFormat -SubMode 'lint' `
                -ExtraArgs (@('--strict', '--recursive') + $fmtConfigArgs + $Paths)
            if ($code -ne 0) { $failed = $true }
        }
        else {
            Write-Warning 'swift-format not found — skipping format check.'
        }
        if ($hasSwiftLint) {
            Write-Host '>> swiftlint --strict'
            & swiftlint lint --strict @lintConfigArgs
            if ($LASTEXITCODE -ne 0) { $failed = $true }
        }
        else {
            Write-Error 'swiftlint is required for check mode. Install via `brew install swiftlint`.'
            $failed = $true
        }
    }
    'lint' {
        if ($hasSwiftLint) {
            Write-Host '>> swiftlint --strict'
            & swiftlint lint --strict @lintConfigArgs
            if ($LASTEXITCODE -ne 0) { $failed = $true }
        }
        else {
            Write-Error 'swiftlint is required for lint mode. Install via `brew install swiftlint`.'
            $failed = $true
        }
    }
}

if ($failed) {
    Write-Error "swift-lint failed (mode: $Mode)."
    exit 1
}

Write-Host "OK swift-lint passed (mode: $Mode)."
exit 0
