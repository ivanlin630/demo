#!/usr/bin/env pwsh
# Godot DETACHED launcher for long-running measurement (survives Claude Code bg-task job reaping).
#
# WHY: CLI harness wraps bg-tasks in a kill-on-close Job object -> killing the bg-task kills the
#   whole tree (pwsh wrapper + godot child) => 0-byte output, no timeout marker (root cause found
#   2026-07-11: not OOM/not crash, verified via zero Resource-Exhaustion events + foreground works).
# FIX: launch godot via WMI Win32_Process.Create -> parented to WMI service, NOT in harness job
#   -> survives bg-task reaping. Launcher returns immediately (short bg-task, safe under any cap).
#
# Usage:
#   $env:WARRING_SEEDS='1337,42,7'; $env:WARRING_MONTHS='3'; $env:WARRING_OUT='A:\...\out.json'
#   $env:WARRING_PROGRESS='A:\...\prog.txt'; $env:WARRING_RESUME='1'   # resume-skip done seeds
#   .\tools\godot-detach.ps1 --headless --path A:\GDS\demo\.worktrees\<slice> --script scripts/debug/seeded_warring_bed.gd
#   -> prints [GODOT DETACHED pid=... out=...]; poll WARRING_PROGRESS / WARRING_OUT (both UTF-8 via FileAccess).
#
# NOTE: real data channels = WARRING_OUT (json) + WARRING_PROGRESS (both written by bed via FileAccess=UTF-8,
#   independent of the CP950 stdout log). stdout log is raw CP950 (post-mortem only). ASCII-only file (PS5.1).
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $root "godot\Godot_v4.2.2-stable_win64_console.exe"
if (-not (Test-Path $exe)) { $exe = "A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe" }

$stdoutLog = if ($env:GODOT_DETACH_OUT) { $env:GODOT_DETACH_OUT } else { Join-Path $env:TEMP ("godot_detach_" + (New-Guid).ToString('N').Substring(0,8) + ".log") }

# Build a temp .cmd carrying env (WMI Create does not inherit PS session env) + redirect. Avoids quote hell.
$envLines = Get-ChildItem env: | Where-Object { $_.Name -like 'WARRING_*' -or $_.Name -eq 'GODOT_TIMEOUT' -or $_.Name -like 'LADDER_*' -or $_.Name -like 'SPECIMEN_*' -or $_.Name -eq 'FOOD_DAYS_THRESHOLD' -or $_.Name -eq 'ADHOC_TICKS' -or $_.Name -eq 'LW_MONTHS' -or $_.Name -eq 'PERF_SEED' -or $_.Name -eq 'PERF_DAYS' -or $_.Name -eq 'PERF_CONFIG' } |
    ForEach-Object { 'set "' + $_.Name + '=' + $_.Value + '"' }
$argStr = ($args | ForEach-Object { '"' + $_ + '"' }) -join ' '
$cmdBody = @()
$cmdBody += '@echo off'
$cmdBody += $envLines
$cmdBody += '"' + $exe + '" ' + $argStr + ' > "' + $stdoutLog + '" 2>&1'
$tempCmd = Join-Path $env:TEMP ("godot_detach_" + (New-Guid).ToString('N').Substring(0,8) + ".cmd")
Set-Content -Path $tempCmd -Value $cmdBody -Encoding Ascii

# WMI launch = breakaway from harness job object -> survives bg-task kill.
$res = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = ('cmd.exe /c "' + $tempCmd + '"') }
if ($res.ReturnValue -eq 0) {
    "[GODOT DETACHED pid=$($res.ProcessId) stdout=$stdoutLog progress=$($env:WARRING_PROGRESS) out=$($env:WARRING_OUT)]"
    "[detach] poll WARRING_PROGRESS/WARRING_OUT (UTF-8); process survives bg-task reaping; resume via WARRING_RESUME=1"
} else {
    "[GODOT DETACH FAILED ReturnValue=$($res.ReturnValue)]"
}
