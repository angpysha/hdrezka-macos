# XcodeCommon.ps1 — shared xcodebuild resolution for ios-native skills.
# Dot-source from skill scripts: . (Join-Path $PSScriptRoot '../lib/XcodeCommon.ps1')

$ErrorActionPreference = 'Stop'

function Test-XcodeCommand {
    if (-not (Get-Command xcodebuild -ErrorAction SilentlyContinue)) {
        throw 'xcodebuild not found. Requires macOS with Xcode installed.'
    }
}

function Resolve-XcodeContainer {
    param(
        [string]$Workspace = '',
        [string]$Project = ''
    )
    if (-not $Workspace -and -not $Project) {
        $ws = Get-ChildItem -Path . -Filter *.xcworkspace -Depth 2 -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch 'project\.xcworkspace$' } | Select-Object -First 1
        if ($ws) { $Workspace = $ws.FullName }
        else {
            $proj = Get-ChildItem -Path . -Filter *.xcodeproj -Depth 2 -ErrorAction SilentlyContinue |
                Select-Object -First 1
            if ($proj) { $Project = $proj.FullName }
        }
    }
    if ($Workspace) { return @{ Args = @('-workspace', $Workspace); Workspace = $Workspace; Project = '' } }
    if ($Project) { return @{ Args = @('-project', $Project); Workspace = ''; Project = $Project } }
    throw 'No .xcworkspace/.xcodeproj found. Pass -Workspace or -Project.'
}

function Resolve-XcodeScheme {
    param(
        [string[]]$ContainerArgs,
        [string]$Scheme = ''
    )
    if ($Scheme) { return $Scheme }
    try {
        $info = (& xcodebuild @ContainerArgs -list -json 2>$null | Out-String) | ConvertFrom-Json
        $schemes = if ($info.workspace) { $info.workspace.schemes } else { $info.project.schemes }
        if ($schemes.Count -gt 0) {
            $detected = $schemes[0]
            Write-Host ">> auto-detected scheme: $detected"
            return $detected
        }
    }
    catch { }
    throw 'Could not auto-detect a scheme. Pass -Scheme.'
}

function Get-XcodePlatformDestination {
    param(
        [ValidateSet('iOS', 'macOS', 'tvOS', 'watchOS', 'visionOS')]
        [string]$Platform = 'iOS'
    )
    switch ($Platform) {
        'iOS' { return 'generic/platform=iOS' }
        'macOS' { return 'generic/platform=macOS' }
        'tvOS' { return 'generic/platform=tvOS' }
        'watchOS' { return 'generic/platform=watchOS' }
        'visionOS' { return 'generic/platform=visionOS' }
    }
}

function Get-XcodeExportTemplateName {
    param(
        [ValidateSet('development', 'ad-hoc', 'app-store-connect', 'enterprise', 'developer-id', 'mac-application')]
        [string]$Method
    )
    @{
        'development'       = 'ExportOptions.development.plist'
        'ad-hoc'              = 'ExportOptions.adhoc.plist'
        'app-store-connect'   = 'ExportOptions.appstore.plist'
        'enterprise'          = 'ExportOptions.enterprise.plist'
        'developer-id'        = 'ExportOptions.developer-id.plist'
        'mac-application'     = 'ExportOptions.mac-application.plist'
    }[$Method]
}

function Get-XcodeDistributionLabel {
    param([string]$Method)
    @{
        'development'       = 'Development (local / registered devices)'
        'ad-hoc'            = 'Ad-hoc (registered devices, OTA)'
        'app-store-connect' = 'TestFlight / App Store Connect'
        'enterprise'        = 'Enterprise (in-house)'
        'developer-id'      = 'Developer ID (macOS, outside Mac App Store)'
        'mac-application'   = 'Mac App Store'
    }[$Method]
}
