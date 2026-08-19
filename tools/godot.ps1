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
