# Extract HERE SDK into plugins/here_sdk/
# 1) Put heresdk-explore-flutter-*.tar.gz in plugins/ (same folder as this script)
# 2) Run: powershell -ExecutionPolicy Bypass -File extract_here_sdk.ps1

$ErrorActionPreference = 'Stop'
$pluginsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$destDir = Join-Path $pluginsDir 'here_sdk'
$archive = Get-ChildItem -Path $pluginsDir -Filter 'heresdk-explore-flutter-*.tar.gz' |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 1

if (-not $archive) {
  Write-Host 'ERROR: Put heresdk-explore-flutter-*.tar.gz in plugins/ first.' -ForegroundColor Red
  exit 1
}

Write-Host "Archive: $($archive.Name)"
$tempDir = Join-Path $pluginsDir ('_here_extract_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
  tar -xf $archive.FullName -C $tempDir
  $root = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
  if (-not $root) { $root = Get-Item $tempDir }

  New-Item -ItemType Directory -Path $destDir -Force | Out-Null
  Get-ChildItem -Path $root.FullName -Force | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $destDir -Recurse -Force
  }

  Write-Host 'OK: HERE SDK copied to plugins/here_sdk/' -ForegroundColor Green
  Get-ChildItem $destDir | Select-Object Name
}
finally {
  Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
