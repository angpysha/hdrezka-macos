# xc-archive.ps1 — create a signed .xcarchive with xcodebuild.
# Default signing comes from the .xcodeproj / .pbxproj (Automatic). Use -SigningStyle Manual for CI.
#
# Usage:
#   pwsh .cursor/skills/xc-archive/scripts/xc-archive.ps1 -Platform iOS
#   pwsh .cursor/skills/xc-archive/scripts/xc-archive.ps1 -Scheme MyApp -Platform macOS
#   pwsh .cursor/skills/xc-archive/scripts/xc-archive.ps1 -SigningStyle Manual -TeamId ABCDE12345
param(
    [string]$Workspace = '',
    [string]$Project = '',
    [string]$Scheme = '',
    [string]$Configuration = 'Release',
    [ValidateSet('iOS', 'macOS', 'tvOS', 'watchOS', 'visionOS')]
    [string]$Platform = 'iOS',
    [string]$Destination = '',
    [string]$OutputDir = 'build',
    [string]$ArchivePath = '',
    [ValidateSet('Automatic', 'Manual')]
    [string]$SigningStyle = 'Automatic',
    [string]$TeamId = $env:APPLE_TEAM_ID,
    [string]$SigningIdentity = $env:APPLE_CERTIFICATE_SIGNING_IDENTITY,
    [string]$ProvisioningProfileUuid = $env:APPLE_PROV_PROFILE_UUID,
    [string]$ProvisioningProfileName = '',
    [switch]$AllowProvisioningUpdates
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..' '..' 'lib' 'XcodeCommon.ps1')

Test-XcodeCommand
$container = Resolve-XcodeContainer -Workspace $Workspace -Project $Project
$Scheme = Resolve-XcodeScheme -ContainerArgs $container.Args -Scheme $Scheme

if (-not $Destination) {
    $Destination = Get-XcodePlatformDestination -Platform $Platform
}

$null = New-Item -ItemType Directory -Force -Path $OutputDir
if (-not $ArchivePath) {
    $ArchivePath = Join-Path $OutputDir "$Scheme.xcarchive"
}

$xcArgs = @() + $container.Args + @(
    '-scheme', $Scheme,
    '-configuration', $Configuration,
    '-destination', $Destination,
    '-archivePath', $ArchivePath,
    'archive',
    "CODE_SIGN_STYLE=$SigningStyle"
)

if ($SigningStyle -eq 'Automatic') {
    if (-not $PSBoundParameters.ContainsKey('AllowProvisioningUpdates')) {
        $AllowProvisioningUpdates = $true
    }
    if ($AllowProvisioningUpdates) {
        $xcArgs += '-allowProvisioningUpdates'
    }
    # Provisioning profile + team are read from pbxproj / Xcode account — do not override.
    Write-Host ">> signing: Automatic (from .xcodeproj / Xcode account)"
}
else {
    if ($TeamId) { $xcArgs += "DEVELOPMENT_TEAM=$TeamId" }
    if ($SigningIdentity) { $xcArgs += "CODE_SIGN_IDENTITY=$SigningIdentity" }
    if ($ProvisioningProfileName) {
        $xcArgs += "PROVISIONING_PROFILE_SPECIFIER=$ProvisioningProfileName"
    }
    elseif ($ProvisioningProfileUuid) {
        $xcArgs += "PROVISIONING_PROFILE=$ProvisioningProfileUuid"
    }
    Write-Host ">> signing: Manual (CI / explicit overrides)"
}

Write-Host ">> xcodebuild archive -scheme $Scheme -platform $Platform -> $ArchivePath"
& xcodebuild @xcArgs
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK archive: $ArchivePath"
}
exit $LASTEXITCODE
