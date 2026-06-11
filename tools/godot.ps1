#!/usr/bin/env pwsh
# Godot wrapper: Godot win console exe writes stdout in system locale (CP950).
# Run via cmd /c redirect to binary log, then transcode CP950 -> UTF-8 for the pipeline.
# Usage: .\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
# Worktree note: tools/godot/*.exe is gitignored (absent in worktrees) -> fallback to main repo path.
# NOTE: keep this file ASCII-only. PS 5.1 reads BOM-less files as ANSI; non-ASCII comments corrupt parsing.
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $root "godot\Godot_v4.2.2-stable_win64_console.exe"
if (-not (Test-Path $exe)) {
    $exe = "A:\GDS\demo\tools\godot\Godot_v4.2.2-stable_win64_console.exe"
}
$tempLog = [System.IO.Path]::GetTempFileName()
$argStr = ($args | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } }) -join ' '
cmd /c "`"$exe`" $argStr > `"$tempLog`" 2>&1"
$bytes = [System.IO.File]::ReadAllBytes($tempLog)
Remove-Item $tempLog -ErrorAction SilentlyContinue
$cp950 = [System.Text.Encoding]::GetEncoding(950)
$utf8Text = $cp950.GetString($bytes)
$utf8Text -split "`r?`n"
