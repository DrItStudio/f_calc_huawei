# Huawei HMS Update-related AAR downloader with dynamic Maven metadata resolution.
# Features:
#  * Queries maven-metadata.xml from multiple Huawei mirrors
#  * Picks latest or constrained version automatically
#  * Falls back to manual version list if metadata blocked
#  * Downloads AARs into android/app/libs for Gradle fileTree inclusion
#
# Usage examples:
#   # Default (latest versions of both artifacts)
#   powershell -ExecutionPolicy Bypass -File scripts/fetch_hms_update_aars.ps1
#   # Specify output dir
#   powershell -File scripts/fetch_hms_update_aars.ps1 -OutDir ../android/app/libs
#   # Constrain versions (regex)
#   powershell -File scripts/fetch_hms_update_aars.ps1 -VersionFilter '6\\.11\\..*' -SdkVersionFilter '3\\.1\\..*'
#   # Force specific versions
#   powershell -File scripts/fetch_hms_update_aars.ps1 -AppUpdateVersion 6.11.0.302 -UpdateSdkVersion 3.1.2.300

param(
  [string]$OutDir               = "../android/app/libs",
  [string]$AppUpdateVersion      = "",          # explicit com.huawei.hms:appupdate version
  [string]$UpdateSdkVersion      = "",          # explicit com.huawei.updatesdk:update-sdk version
  [string]$VersionFilter         = "",          # regex filter for appupdate (if explicit not set)
  [string]$SdkVersionFilter      = "",          # regex filter for update-sdk
  [switch]$LatestOnly                             # if set, ignore fallback static list ordering
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutDir = (Resolve-Path -LiteralPath (Join-Path $ScriptDir $OutDir)).Path

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor 3072 } catch {}

function New-Dir { param([string]$Path) if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Force -Path $Path | Out-Null } }

function Get-Maven-Metadata {
  param(
    [string]$BaseUrl,
    [string]$GroupId,
    [string]$ArtifactId
  )
  $groupPath = $GroupId -replace '\.', '/'
  $metaUrl = "$BaseUrl/$groupPath/$ArtifactId/maven-metadata.xml"
  Write-Host "  -> metadata: $metaUrl" -ForegroundColor DarkGray
  try {
    $resp = Invoke-WebRequest -Uri $metaUrl -UseBasicParsing -TimeoutSec 40 -ErrorAction Stop
    if (-not $resp.Content) { return @() }
    [xml]$xml = $resp.Content
    $versions = @()
    $xml.metadata.versioning.versions.version | ForEach-Object { if ($_ -and $_.Trim() -ne '') { $versions += $_.Trim() } }
    return $versions
  } catch {
    Write-Host "     (metadata fetch failed) $_" -ForegroundColor DarkYellow
    return @()
  }
}

function Select-Version {
  param(
    [string[]]$Versions,
    [string]$RegexFilter
  )
  if (-not $Versions -or $Versions.Count -eq 0) { return $null }
  $filtered = if ($RegexFilter) { $Versions | Where-Object { $_ -match $RegexFilter } } else { $Versions }
  if (-not $filtered -or $filtered.Count -eq 0) { return $null }
  # Sort semantic-ish: split by non-digit boundaries, pad numeric segments
  $sorted = $filtered | Sort-Object { $_ -split '(?<=\d)\D|\D(?=\d)|(?<!\d)\.(?!\d)' } -Descending
  return $sorted[0]
}

function Download-AAR {
  param(
    [string]$BaseUrl,
    [string]$GroupId,
    [string]$ArtifactId,
    [string]$Version,
    [string]$DestDir
  )
  $groupPath = $GroupId -replace '\.', '/'
  $url = "$BaseUrl/$groupPath/$ArtifactId/$Version/$ArtifactId-$Version.aar"
  $outFile = Join-Path $DestDir ("$ArtifactId-$Version.aar")
  Write-Host "  -> trying $url" -ForegroundColor Cyan
  try {
    try {
      Start-BitsTransfer -Source $url -Destination $outFile -DisplayName "HMS $ArtifactId" -ErrorAction Stop
    } catch {
      Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
    }
    if ((Test-Path $outFile) -and ((Get-Item $outFile).Length -gt 0)) {
      Write-Host "     downloaded: $outFile" -ForegroundColor Green
      return $outFile
    }
  } catch {
    Write-Host "     failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
  }
  return $null
}

$Mirrors = @(
  'https://developer.huawei.com/repo',
  'https://repo.huaweicloud.com/repository/maven',
  'https://mirrors.huaweicloud.com/repository/maven',
  'https://repo.hihonor.com/honor-maven'
)

# Static fallback lists in case metadata blocked
$FallbackAppUpdate = @('6.12.0.302','6.12.0.301','6.12.0.300','6.11.0.302','6.10.0.302','6.10.0.301','6.9.0.300','6.5.0.300','6.3.0.300')
$FallbackUpdateSdk = @('3.1.2.300','3.1.0.300','3.0.2.300','3.0.1.300')

New-Dir -Path $OutDir

$results = @()

function Resolve-And-Download {
  param(
    [string]$GroupId,
    [string]$ArtifactId,
    [string]$ExplicitVersion,
    [string]$RegexFilter,
    [string[]]$FallbackVersions
  )
  Write-Host ("=== {0}:{1} ===" -f $GroupId,$ArtifactId) -ForegroundColor Yellow
  $chosen = $null
  if ($ExplicitVersion) {
    Write-Host "  explicit version requested: $ExplicitVersion" -ForegroundColor Magenta
    $chosen = $ExplicitVersion
  } else {
    $allVersions = @()
    foreach ($m in $Mirrors) {
      $metaVers = Get-Maven-Metadata -BaseUrl $m -GroupId $GroupId -ArtifactId $ArtifactId
      if ($metaVers.Count -gt 0) { $allVersions += $metaVers }
    }
    $allVersions = $allVersions | Sort-Object -Unique
    if ($allVersions.Count -gt 0) {
      Write-Host "  metadata versions found: $($allVersions -join ', ')" -ForegroundColor DarkGray
      if ($LatestOnly) { $RegexFilter = $RegexFilter } # keep filter if provided
      $chosen = Select-Version -Versions $allVersions -RegexFilter $RegexFilter
    }
    if (-not $chosen) {
      Write-Host "  metadata unavailable or no match; using fallback list" -ForegroundColor DarkYellow
      $fallbackOrdered = $FallbackVersions
      if ($RegexFilter) { $fallbackOrdered = $fallbackOrdered | Where-Object { $_ -match $RegexFilter } }
      $chosen = $fallbackOrdered | Select-Object -First 1
    }
  }
  if (-not $chosen) {
  Write-Warning ("  Could not determine version for {0}:{1}" -f $GroupId,$ArtifactId)
    return
  }
  Write-Host "  selected version: $chosen" -ForegroundColor Green
  foreach ($m in $Mirrors) {
    $file = Download-AAR -BaseUrl $m -GroupId $GroupId -ArtifactId $ArtifactId -Version $chosen -DestDir $OutDir
    if ($file) { $results += $file; return }
  }
  Write-Warning ("  All mirrors failed for {0}:{1}:{2}" -f $GroupId,$ArtifactId,$chosen)
}

Resolve-And-Download -GroupId 'com.huawei.hms'       -ArtifactId 'appupdate'  -ExplicitVersion $AppUpdateVersion -RegexFilter $VersionFilter    -FallbackVersions $FallbackAppUpdate
Resolve-And-Download -GroupId 'com.huawei.updatesdk' -ArtifactId 'update-sdk' -ExplicitVersion $UpdateSdkVersion -RegexFilter $SdkVersionFilter -FallbackVersions $FallbackUpdateSdk

Write-Host ""; Write-Host "Summary:" -ForegroundColor Yellow
if ($results.Count -gt 0) {
  Write-Host ("  Downloaded: {0}" -f $results.Count) -ForegroundColor Green
  $results | ForEach-Object { Write-Host "    - $_" }
} else {
  Write-Host "  Downloaded: 0" -ForegroundColor Red
}

Write-Host ("`nAAR files are in: {0}" -f $OutDir) -ForegroundColor Yellow
Write-Host 'Gradle picks up *.aar via implementation(fileTree(dir:"libs")) in build.gradle.kts.' -ForegroundColor Yellow

if ($results.Count -eq 0) {
  Write-Host "Troubleshooting:" -ForegroundColor Cyan
  Write-Host "  * Check VPN / firewall to Huawei Maven repos." -ForegroundColor Cyan
  Write-Host "  * Try specifying -AppUpdateVersion / -UpdateSdkVersion explicitly." -ForegroundColor Cyan
  Write-Host "  * Run Gradle task :app:fetchHmsAars as alternative." -ForegroundColor Cyan
}
