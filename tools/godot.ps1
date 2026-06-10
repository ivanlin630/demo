#!/usr/bin/env pwsh
# Godot wrapper：Godot Windows console.exe 寫 stdout 用 system locale (CP950 in Taiwan)。
# 用 cmd /c redirect 寫 binary log，read 後 CP950 → UTF-8 轉碼，給 PowerShell pipeline。
# Usage: .\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
$tempLog = [System.IO.Path]::GetTempFileName()
$exe = "$PSScriptRoot\godot\Godot_v4.2.2-stable_win64_console.exe"
$argStr = ($args | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } }) -join ' '
cmd /c "`"$exe`" $argStr > `"$tempLog`" 2>&1"
$bytes = [System.IO.File]::ReadAllBytes($tempLog)
Remove-Item $tempLog -ErrorAction SilentlyContinue
$cp950 = [System.Text.Encoding]::GetEncoding(950)
$utf8Text = $cp950.GetString($bytes)
$utf8Text -split "`r?`n"
