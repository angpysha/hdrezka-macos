# xcode-build.ps1 — compile-only build gate (no signing).
# For archive / export use xc-archive and xc-export skills.
#
# Usage:
#   pwsh .cursor/skills/xcode-build/scripts/xcode-build.ps1
#   pwsh .cursor/skills/xcode-build/scripts/xcode-build.ps1 -Scheme MyApp -Platform macOS
#
# Legacy -Action archive|export delegates to xc-archive / xc-export (Manual signing).
param(
    [ValidateSet('build', 'archive', 'export')]
    [string]$Action = 'build',
    [string]$Workspace = '',
    [string]$Project = '',
    [string]$Scheme = '',
    [string]$Configuration = 'Release',
    [ValidateSet('iOS', 'macOS', 'tvOS', 'watchOS', 'visionOS')]
    [string]$Platform = 'iOS',
    [string]$Destination = '',
    [string]$OutputDir = 'build',
    [ValidateSet('development', 'ad-hoc', 'app-store-connect', 'enterprise', 'developer-id', 'mac-application')]
    [string]$Method = 'app-store-connect',
    [string]$TeamId = $env:APPLE_TEAM_ID,
    [string]$SigningIdentity = $env:APPLE_CERTIFICATE_SIGNING_IDENTITY,
    [string]$ProvisioningProfileUuid = $env:APPLE_PROV_PROFILE_UUID,
    [string]$ProvisioningProfileName = '',
    [string]$ExportOptionsPlist = ''
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..' '..' 'lib' 'XcodeCommon.ps1')

Test-XcodeCommand

if ($Action -eq 'archive') {
    Write-Warning 'xcode-build -Action archive is deprecated — use skills/xc-archive instead.'
    $archiveScript = Join-Path $PSScriptRoot '..' '..' 'xc-archive' 'scripts' 'xc-archive.ps1'
    & pwsh -NoProfile -File $archiveScript `
        -Workspace $Workspace -Project $Project -Scheme $Scheme `
        -Configuration $Configuration -Platform $Platform -Destination $Destination `
        -OutputDir $OutputDir -SigningStyle Manual `
        -TeamId $TeamId -SigningIdentity $SigningIdentity `
        -ProvisioningProfileUuid $ProvisioningProfileUuid -ProvisioningProfileName $ProvisioningProfileName
    exit $LASTEXITCODE
}

if ($Action -eq 'export') {
    Write-Warning 'xcode-build -Action export is deprecated — use skills/xc-export instead.'
    $exportScript = Join-Path $PSScriptRoot '..' '..' 'xc-export' 'scripts' 'xc-export.ps1'
    & pwsh -NoProfile -File $exportScript `
        -Scheme $Scheme -OutputDir $OutputDir -Method $Method -ExportOptionsPlist $ExportOptionsPlist
    exit $LASTEXITCODE
}

$container = Resolve-XcodeContainer -Workspace $Workspace -Project $Project
$Scheme = Resolve-XcodeScheme -ContainerArgs $container.Args -Scheme $Scheme
if (-not $Destination) {
    $Destination = Get-XcodePlatformDestination -Platform $Platform
}

$xcArgs = @() + $container.Args + @(
    '-scheme', $Scheme,
    '-configuration', $Configuration,
    '-destination', $Destination,
    'CODE_SIGNING_ALLOWED=NO',
    'build'
)
Write-Host ">> xcodebuild build -scheme $Scheme -platform $Platform (no signing)"
& xcodebuild @xcArgs
exit $LASTEXITCODE
