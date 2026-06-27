# Install Cursor Ecosystem to ~/.cursor
$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot
$Dst = Join-Path $env:USERPROFILE ".cursor"

foreach ($dir in @("skills", "commands", "agents", "hooks", "memory")) {
    $src = Join-Path $RepoRoot $dir
    if (Test-Path $src) {
        $target = Join-Path $Dst $dir
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Copy-Item -Recurse -Force "$src\*" $target
        Write-Host "OK $dir"
    }
}

$hooksJson = Join-Path $RepoRoot "hooks.json"
if (Test-Path $hooksJson) {
    Copy-Item -Force $hooksJson (Join-Path $Dst "hooks.json")
    Write-Host "OK hooks.json"
}

Write-Host ""
Write-Host "Installed to $Dst"
Write-Host "Restart Cursor or open a new Agent chat."
