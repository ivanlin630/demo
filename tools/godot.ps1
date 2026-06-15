#!/usr/bin/env pwsh
# Godot wrapper: Godot win console exe writes stdout in system locale (CP950).
# Launch with a hard timeout (kill if it hangs), then transcode CP950 -> UTF-8.
# Usage: .\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
# Timeout: default 360s; override via env GODOT_TIMEOUT (seconds).
#   Guards against: assert-before-quit idle hang + concurrent import-lock deadlock.
# Worktree note: tools/godot/*.exe is gitignored (absent in worktrees) -> fallback to main repo path.
# NOTE: keep this file ASCII-only. PS 5.1 reads BOM-less files as ANSI; non-ASCII comments corrupt parsing.
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $root "godot\Godot_v4.2.2-stable_win64_console.exe"
if (-not (Test-Path $exe)) {
    $exe = "A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe"
}
$timeoutSec = if ($env:GODOT_TIMEOUT) { [int]$env:GODOT_TIMEOUT } else { 360 }
$tempOut = [System.IO.Path]::GetTempFileName()
$tempErr = [System.IO.Path]::GetTempFileName()
$proc = Start-Process -FilePath $exe -ArgumentList $args `
    -RedirectStandardOutput $tempOut -RedirectStandardError $tempErr `
    -NoNewWindow -PassThru
$timedOut = $false
if (-not $proc.WaitForExit($timeoutSec * 1000)) {
    $timedOut = $true
    try { $proc.Kill() } catch {}
    try { $proc.WaitForExit() } catch {}
}
$cp950 = [System.Text.Encoding]::GetEncoding(950)
$bytesOut = [System.IO.File]::ReadAllBytes($tempOut)
$bytesErr = [System.IO.File]::ReadAllBytes($tempErr)
Remove-Item $tempOut, $tempErr -ErrorAction SilentlyContinue
$text = $cp950.GetString($bytesOut) + $cp950.GetString($bytesErr)
$text -split "`r?`n"
if ($timedOut) { "[GODOT TIMEOUT ${timeoutSec}s - process killed]" }
