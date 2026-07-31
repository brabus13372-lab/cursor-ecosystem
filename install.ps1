# Install Cursor Ecosystem to ~/.cursor
# Usage:
#   .\install.ps1              # install (overwrite)
#   .\install.ps1 -DryRun      # plan only - no writes
#   .\install.ps1 -Backup      # snapshot existing targets before overwrite
#   .\install.ps1 -DryRun -Backup  # show plan + would-be backup path
param(
    [switch]$DryRun,
    [switch]$Backup
)

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot
$Dst = Join-Path $env:USERPROFILE ".cursor"
$Dirs = @("skills", "commands", "agents", "hooks", "memory")

function Get-FileCount([string]$Path) {
    if (-not (Test-Path $Path)) { return 0 }
    return @(Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue).Count
}

function Get-NewestMtime([string]$Path) {
    if (-not (Test-Path $Path)) { return $null }
    $files = Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue
    if (-not $files) { return $null }
    return ($files | Measure-Object -Property LastWriteTime -Maximum).Maximum
}

Write-Host "Source: $RepoRoot"
Write-Host "Target: $Dst"
if ($DryRun) { Write-Host "Mode:   DRY-RUN (no writes)" }
if ($Backup) { Write-Host "Mode:   BACKUP before overwrite" }
Write-Host ""

# Drift summary
$drift = $false
foreach ($dir in $Dirs) {
    $src = Join-Path $RepoRoot $dir
    $target = Join-Path $Dst $dir
    if (-not (Test-Path $src)) { continue }
    $srcN = Get-FileCount $src
    $dstN = Get-FileCount $target
    $srcM = Get-NewestMtime $src
    $dstM = Get-NewestMtime $target
    $status = "ok"
    if ((Test-Path $target) -and ($srcN -ne $dstN -or ($dstM -and $srcM -and $dstM -gt $srcM))) {
        $status = "DIFFERS"
        $drift = $true
    } elseif (-not (Test-Path $target)) {
        $status = "missing - will create"
    }
    Write-Host ("  {0,-10} repo={1,4} files  dest={2,4} files  {3}" -f $dir, $srcN, $dstN, $status)
}

$hooksSrc = Join-Path $RepoRoot "hooks.json"
$hooksDst = Join-Path $Dst "hooks.json"
if (Test-Path $hooksSrc) {
    $hStatus = "ok"
    if (Test-Path $hooksDst) {
        $srcHash = (Get-FileHash -LiteralPath $hooksSrc -Algorithm SHA256).Hash
        $dstHash = (Get-FileHash -LiteralPath $hooksDst -Algorithm SHA256).Hash
        if ($srcHash -ne $dstHash) {
            $hStatus = "DIFFERS"
            $drift = $true
        }
    } else {
        $hStatus = "missing - will create"
    }
    Write-Host ("  {0,-10} {1}" -f "hooks.json", $hStatus)
}

if ($drift) {
    Write-Host ""
    Write-Host "WARNING: destination differs from repo (counts and/or newer dest mtimes / hooks.json hash)."
    Write-Host "         Local-only edits in ~/.cursor may be overwritten. Prefer -Backup."
}

# Backup
$backupRoot = $null
if ($Backup) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupRoot = Join-Path $env:USERPROFILE ".cursor-backup-$stamp"
    if ($DryRun) {
        Write-Host ""
        Write-Host "Would backup existing targets -> $backupRoot"
    } else {
        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        foreach ($dir in $Dirs) {
            $target = Join-Path $Dst $dir
            if (Test-Path $target) {
                Copy-Item -Recurse -Force $target (Join-Path $backupRoot $dir)
                Write-Host "BACKUP $dir"
            }
        }
        if (Test-Path $hooksDst) {
            Copy-Item -Force $hooksDst (Join-Path $backupRoot "hooks.json")
            Write-Host "BACKUP hooks.json"
        }
        Write-Host "Backup saved: $backupRoot"
    }
}

Write-Host ""
foreach ($dir in $Dirs) {
    $src = Join-Path $RepoRoot $dir
    if (-not (Test-Path $src)) { continue }
    $target = Join-Path $Dst $dir
    if ($DryRun) {
        Write-Host "PLAN copy $dir -> $target"
    } else {
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Copy-Item -Recurse -Force "$src\*" $target
        Write-Host "OK $dir"
    }
}

if (Test-Path $hooksSrc) {
    if ($DryRun) {
        Write-Host "PLAN copy hooks.json -> $hooksDst"
    } else {
        Copy-Item -Force $hooksSrc $hooksDst
        Write-Host "OK hooks.json"
    }
}

Write-Host ""
if ($DryRun) {
    Write-Host "Dry-run complete - nothing written to $Dst"
    exit 0
}
Write-Host "Installed to $Dst"
Write-Host "Restart Cursor or open a new Agent chat."
