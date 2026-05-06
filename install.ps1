# Mouse-jiggler installer for Windows.
#
# Usage (PowerShell):
#   irm https://raw.githubusercontent.com/WanderingBread0/Mouse-jiggler/main/install.ps1 | iex
#
# Environment overrides:
#   $env:INSTALL_DIR  destination directory
#   $env:VERSION      release tag (default: latest)
#   $env:REPO         owner/name override for forks
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$Repo       = if ($env:REPO)        { $env:REPO }        else { 'WanderingBread0/Mouse-jiggler' }
$Version    = if ($env:VERSION)     { $env:VERSION }     else { 'latest' }
$InstallDir = if ($env:INSTALL_DIR) { $env:INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\mouse-jiggler' }

$arch = switch ($env:PROCESSOR_ARCHITECTURE) {
  'AMD64' { 'x86_64' }
  'ARM64' { 'arm64' }
  default { throw "Unsupported architecture: $($env:PROCESSOR_ARCHITECTURE)" }
}

$asset = "mouse-jiggler-windows-$arch.exe"
if ($Version -eq 'latest') {
  $url      = "https://github.com/$Repo/releases/latest/download/$asset"
  $sumsUrl  = "https://github.com/$Repo/releases/latest/download/SHA256SUMS"
} else {
  $url      = "https://github.com/$Repo/releases/download/$Version/$asset"
  $sumsUrl  = "https://github.com/$Repo/releases/download/$Version/SHA256SUMS"
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$dest = Join-Path $InstallDir 'mouse-jiggler.exe'
$tmp  = [System.IO.Path]::GetTempFileName()

Write-Host "==> Downloading $asset" -ForegroundColor Cyan
try {
  Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
} catch {
  Remove-Item -Force $tmp -ErrorAction SilentlyContinue
  throw "Download failed: $url`n$_"
}

# Best-effort checksum verification.
try {
  $sumsPath = "$tmp.sums"
  Invoke-WebRequest -Uri $sumsUrl -OutFile $sumsPath -UseBasicParsing -ErrorAction Stop
  $expected = (Get-Content $sumsPath | ForEach-Object {
      $parts = $_ -split '\s+', 2
      if ($parts.Length -eq 2 -and ($parts[1] -eq $asset -or $parts[1] -eq "*$asset")) { $parts[0] }
  } | Select-Object -First 1)
  if ($expected) {
    $actual = (Get-FileHash -Algorithm SHA256 -Path $tmp).Hash.ToLower()
    if ($actual -ne $expected.ToLower()) {
      Remove-Item -Force $tmp, $sumsPath -ErrorAction SilentlyContinue
      throw "Checksum mismatch for $asset"
    }
    Write-Host "==> Checksum verified" -ForegroundColor Cyan
  }
  Remove-Item -Force $sumsPath -ErrorAction SilentlyContinue
} catch [System.Net.WebException] {
  # SHA256SUMS not published for this release; skip.
}

# Unblock so SmartScreen / Mark-of-the-Web doesn't nag.
try { Unblock-File -Path $tmp -ErrorAction SilentlyContinue } catch { }

Move-Item -Force -Path $tmp -Destination $dest
Write-Host "==> Installed: $dest" -ForegroundColor Cyan

# Add to user PATH if not already there.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$onPath   = ($userPath -split ';') -contains $InstallDir
if (-not $onPath) {
  $newPath = if ([string]::IsNullOrEmpty($userPath)) { $InstallDir } else { "$userPath;$InstallDir" }
  [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
  Write-Host "==> Added $InstallDir to your user PATH (open a new terminal to pick it up)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Run it with: mouse-jiggler" -ForegroundColor Green
