#!/usr/bin/env pwsh
# Godot wrapper: Godot win console exe writes stdout in system locale (CP950).
# Launch with a hard timeout (kill if it hangs), then transcode CP950 -> UTF-8.
# Usage: .\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
# Timeout: default 360s; override via env GODOT_TIMEOUT (seconds).
#   Guards against: assert-before-quit idle hang + concurrent import-lock deadlock.
# Worktree note: tools/godot/*.exe is gitignored (absent in worktrees) -> fallback to main repo path.
# NOTE: keep this file ASCII-only. PS 5.1 reads BOM-less files as ANSI; non-ASCII comments corrupt parsing.
# STDOUT ENCODING (2026-09-04). This wrapper decodes Godot's CP950 bytes into .NET strings,
# but PS 5.1 then RE-ENCODES them on the way out using the ANSI codepage whenever stdout is
# redirected (a file, or a pipe into any caller). So the transcode above was undone at the last
# step and consumers got CP950 after all. It went unnoticed for a long time because every
# godot-backed merge gate happens to have an ASCII-only expect string -- i.e. the bug was
# invisible to the channel we check through. Measured before/after with a two-char probe:
# without this line the bytes are b2 cf ae da (CP950); with it they decode as U+7D2E U+6839.
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
# CALLER CONTRACT (2026-09-04, measured -- this is a real limit, not a style note).
# The line above only takes effect while nothing has written to stdout yet in this process
# chain. PowerShell fixes its host output writer on first write, and neither
# [Console]::OutputEncoding nor [Console]::SetOut can retarget it afterwards (both tried,
# both failed). So:
#   powershell -File tools/godot.ps1 ...            -> UTF-8 (verified: U+7D2E U+6839)
#   a.ps1 prints, then calls tools/godot.ps1        -> CP950 (verified: b2 cf ae da)
#   a.ps1 writes to STDERR, then calls this script  -> UTF-8 (verified)
# A launcher that wants to announce something before the run must use
# [Console]::Error.WriteLine(...), not plain output. This bit us once already: a detached
# warring run printed its env banner to stdout first and the whole 90-day log came back CP950.
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
# STREAMING (2026-09-03, systems). The old shape redirected stdout to a temp file and printed
# it only after the process exited. That is correct output but wrong timing: if THIS wrapper is
# killed from outside (an outer timeout), the caller gets ZERO bytes even though the run had
# already printed thousands of lines. Measured: a 3-seed measurement was lost exactly that way.
# Streaming keeps the CP950->UTF-8 transcode (that is the only reason the temp file exists) but
# emits as the run goes. Decode only up to the LAST COMPLETE NEWLINE -- CP950 is multi-byte and
# a chunk boundary in the middle of a character produces mojibake.
# Verified before swapping: byte-identical output vs the old shape on material_hold_test /
# settlement_s2b_test / seam1_registry_test, AND the point of the change -- killed from outside,
# old shape produced 0 bytes, this one produced 713751 bytes.
$cp950 = [System.Text.Encoding]::GetEncoding(950)
$proc = Start-Process -FilePath $exe -ArgumentList $args `
    -RedirectStandardOutput $tempOut -RedirectStandardError $tempErr `
    -NoNewWindow -PassThru
$sb = New-Object System.Text.StringBuilder
$script:pos = 0
function Pump-Out {
    if (-not (Test-Path $tempOut)) { return }
    try {
        $fs = New-Object System.IO.FileStream($tempOut, [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        try {
            if ($fs.Length -le $script:pos) { return }
            $fs.Position = $script:pos
            $buf = New-Object byte[] ($fs.Length - $script:pos)
            $n = $fs.Read($buf, 0, $buf.Length)
            $last = -1
            for ($i = $n - 1; $i -ge 0; $i--) { if ($buf[$i] -eq 10) { $last = $i; break } }
            if ($last -lt 0) { return }
            $chunk = $cp950.GetString($buf, 0, $last + 1)
            $script:pos = $script:pos + $last + 1
            [void]$sb.Append($chunk)
            # $chunk always ends with a newline, so -split leaves a trailing "" element: drop ONLY
            # that last one. Interior blank lines are real output and must survive.
            $parts = $chunk -split "`r?`n"
            for ($k = 0; $k -lt ($parts.Count - 1); $k++) { $parts[$k] }
        } finally { $fs.Dispose() }
    } catch { }
}
$deadline = (Get-Date).AddSeconds($timeoutSec)
$timedOut = $false
while (-not $proc.HasExited) {
    Pump-Out
    if ((Get-Date) -gt $deadline) { $timedOut = $true; try { $proc.Kill() } catch {}; break }
    Start-Sleep -Milliseconds 150
}
try { [void]$proc.WaitForExit(5000) } catch {}
Pump-Out
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
$bytesOut = Read-BytesTolerant $tempOut
$bytesErr = Read-BytesTolerant $tempErr
Remove-Item $tempOut, $tempErr -ErrorAction SilentlyContinue
$fullOut = $cp950.GetString($bytesOut)
$errText = $cp950.GetString($bytesErr)
# Reproduce the old boundary EXACTLY: the old shape did ONE split over ($out + $err), so no blank
# line appears between stdout and stderr, and a trailing "" IS emitted when the text ends with a
# newline. The complete lines were already streamed (without that trailing ""), so emit the rest.
$rest = $fullOut.Substring([Math]::Min($sb.Length, $fullOut.Length)) + $errText
$rest -split "`r?`n"
$text = $fullOut + $errText
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
