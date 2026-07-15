# xc-export.ps1 — export .ipa / .pkg from an .xcarchive using ExportOptions.
#
# Usage:
#   pwsh .cursor/skills/xc-export/scripts/xc-export.ps1 -Method app-store-connect
#   pwsh .cursor/skills/xc-export/scripts/xc-export.ps1 -ArchivePath build/MyApp.xcarchive -Method ad-hoc
param(
    [string]$ArchivePath = '',
    [string]$Scheme = '',
    [string]$OutputDir = 'build',
    [string]$ExportDir = '',
    [ValidateSet('development', 'ad-hoc', 'app-store-connect', 'enterprise', 'developer-id', 'mac-application')]
    [string]$Method = '',
    [string]$ExportOptionsPlist = '',
    [ValidateSet('Automatic', 'Manual')]
    [string]$SigningStyle = ''
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..' '..' 'lib' 'XcodeCommon.ps1')

Test-XcodeCommand

if (-not $Method) {
    Write-Error 'Pass -Method: development | ad-hoc | app-store-connect | enterprise | developer-id | mac-application'
    exit 1
}

if (-not $ArchivePath) {
    if (-not $Scheme) {
        $container = Resolve-XcodeContainer
        $Scheme = Resolve-XcodeScheme -ContainerArgs $container.Args -Scheme ''
    }
    $ArchivePath = Join-Path $OutputDir "$Scheme.xcarchive"
}

if (-not (Test-Path $ArchivePath)) {
    Write-Error "Archive not found: $ArchivePath. Run xc-archive first or pass -ArchivePath."
    exit 1
}

if (-not $ExportOptionsPlist) {
    $tmplName = Get-XcodeExportTemplateName -Method $Method
    $ExportOptionsPlist = Join-Path $PSScriptRoot '..' 'templates' $tmplName
}

if (-not (Test-Path $ExportOptionsPlist)) {
    Write-Error "ExportOptions plist not found: $ExportOptionsPlist. Pass -ExportOptionsPlist or copy templates/ into the repo."
    exit 1
}

if (-not $ExportDir) {
    $ExportDir = Join-Path $OutputDir 'export'
}
$null = New-Item -ItemType Directory -Force -Path $ExportDir

$label = Get-XcodeDistributionLabel -Method $Method
Write-Host ">> export method: $Method ($label)"

$xcArgs = @(
    '-exportArchive',
    '-archivePath', $ArchivePath,
    '-exportPath', $ExportDir,
    '-exportOptionsPlist', $ExportOptionsPlist
)

Write-Host ">> xcodebuild -exportArchive -> $ExportDir"
& xcodebuild @xcArgs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$artifacts = @(
    Get-ChildItem -Path $ExportDir -Filter *.ipa -ErrorAction SilentlyContinue
    Get-ChildItem -Path $ExportDir -Filter *.pkg -ErrorAction SilentlyContinue
)
foreach ($a in $artifacts) {
    Write-Host "OK artifact: $($a.FullName)"
}
if ($artifacts.Count -eq 0) {
    Write-Host "OK export directory: $ExportDir (check for .app or nested outputs)"
}
exit 0
