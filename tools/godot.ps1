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
# Class-cache guard (2026-09-03). A fresh checkout (e.g. `git worktree add` of an old
# commit) has no .godot/global_script_class_cache.cfg. Without it EVERY class_name type
# fails to resolve, the script is never loaded, and the run prints parse errors only --
# i.e. a grep for failures returns ZERO, which reads exactly like "ran fine, all clean".
# That misread already happened twice in one day, in opposite directions:
#   "cache missing" read as "the bed is broken", and "cache missing" read as "the tree was clean".
# Cost note (measured, not guessed): --import takes ~22s even on an already-imported tree,
# so running it unconditionally would add ~22s to EVERY call (merge-gates has 12 of them).
# Therefore: import only when the cache file is ABSENT, and say so on stdout.
# The check itself is one Test-Path, i.e. free on the normal path.
# HONEST LIMIT (systems, 2026-09-03): this guards ABSENT cache only, NOT a STALE one.
#   Adding a new `class_name` file leaves the cache present but outdated -- the run then
#   reports `Identifier "X" not declared`, which reads like "the change broke it".
#   That is the exact failure that hit systems this morning, and this guard does NOT cover it.
#   Rule of thumb that still applies: after adding a class_name file, run --import yourself.
$skipCacheGuard = $false
foreach ($a in $args) { if ($a -eq "--import") { $skipCacheGuard = $true } }
if (-not $skipCacheGuard) {
    $projPath = (Get-Location).Path
    for ($i = 0; $i -lt ($args.Count - 1); $i++) {
        if ($args[$i] -eq "--path") { $projPath = $args[$i + 1] }
    }
    $cacheFile = Join-Path $projPath ".godot\global_script_class_cache.cfg"
    if (-not (Test-Path $cacheFile)) {
        Write-Output "[godot.ps1] class cache MISSING: $cacheFile"
        Write-Output "[godot.ps1] running --import first (one-off, ~20s). Without it every class_name type"
        Write-Output "[godot.ps1] fails to resolve and this run would print ZERO failures while testing NOTHING."
        $imp = Start-Process -FilePath $exe -ArgumentList @("--headless", "--path", $projPath, "--import") -NoNewWindow -PassThru -Wait
        Write-Output "[godot.ps1] import finished (exit $($imp.ExitCode)); continuing with the requested run."
    }
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
    # Bounded grace: killed process still owns the stdout/stderr redirect handles for a moment.
    # Unbounded WaitForExit could hang the wrapper; 5s is ample for handle teardown.
    try { [void]$proc.WaitForExit(5000) } catch {}
}
# Read redirect files tolerantly: after a Kill the handles may not be released yet, so
# ReadAllBytes throws "being used by another process" and the whole stdout vanishes.
# FileShare::ReadWrite lets us read while the handle lives; retry with backoff covers the
# brief window where even shared open is refused. Returns empty array only if all attempts fail.
# Note: returns are comma-wrapped and typed [byte[]] - PowerShell unrolls arrays on output,
# which turns an empty (0-byte) file into $null and breaks Encoding.GetString().
function Read-BytesTolerant([string]$path) {
    for ($i = 0; $i -lt 5; $i++) {
        try {
            $fs = New-Object System.IO.FileStream($path, [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            try {
                $ms = New-Object System.IO.MemoryStream
                try { $fs.CopyTo($ms); return ,[byte[]]$ms.ToArray() } finally { $ms.Dispose() }
            } finally { $fs.Dispose() }
        } catch {
            Start-Sleep -Milliseconds 300
        }
    }
    return ,[byte[]]@()
}
$cp950 = [System.Text.Encoding]::GetEncoding(950)
$bytesOut = Read-BytesTolerant $tempOut
$bytesErr = Read-BytesTolerant $tempErr
Remove-Item $tempOut, $tempErr -ErrorAction SilentlyContinue
$text = $cp950.GetString($bytesOut) + $cp950.GetString($bytesErr)
$text -split "`r?`n"
if ($timedOut) { "[GODOT TIMEOUT ${timeoutSec}s - process killed]" }
# Stale-cache detector (2026-09-03). The guard above only covers a MISSING cache.
# A cache that EXISTS but is out of date (a new class_name file was added and nobody
# re-imported) produces the same family of symptom -- unresolved class_name types --
# and that reads like "the change I just made broke it". Half a guard is worse than none
# here, because after the missing-cache guard exists people stop suspecting this direction.
# So: after the run, if the output mentions unresolved types WHILE the cache file exists,
# say so. This detector cannot tell "stale cache" from "that class really does not exist",
# so the message names both, and it does NOT re-import on its own.
if ((-not $skipCacheGuard) -and (Test-Path $cacheFile)) {
    if ($text -match 'Could not find type "|Identifier ".*" not declared') {
        Write-Output "[godot.ps1] unresolved class_name type(s) above, while the cache EXISTS: $cacheFile"
        Write-Output "[godot.ps1] two causes look identical here: (a) cache is STALE (new class_name added"
        Write-Output "[godot.ps1] without --import) or (b) that type genuinely does not exist. Try --import first."
    }
}
