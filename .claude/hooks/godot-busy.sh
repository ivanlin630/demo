#!/usr/bin/env bash
# godot-busy.sh —— ★「機器上還有沒有 Godot 引擎在跑」的唯一判準（systems 2026-09-22）
#
# ★★★為什麼不是 `CommandLine -like '*godot*'`：
#   那個謂詞會把【命令列裡【提到】godot 的閒置 shell】算進來 —— 實測同一時刻
#   CommandLine 版 = 8（其中 bash.exe x5、powershell.exe x1），ProcessName 版 = 2。
#   ★而呼叫它的那個 Bash 工具 shell，命令列裡通常就有 `godot`
#   ⇒ **它永遠不會回報 0** ⇒ 拿來當「機器空了」的判準會【永遠紅】，而永遠紅的守衛會被繞過。
# ★★所以謂詞是 **ProcessName（引擎自己的名字）**，不是 CommandLine。
# ★★★而【一次跑】會出現 **2 個行程**（`_console.exe` + `.exe`）⇒ 2 不是「兩輪」。
#
# 輸出（★全 ASCII：中文經 powershell.exe→bash 這條管道會變 CP950 亂碼）
#   GODOT-BUSY n=<引擎行程數>
#   然後每支一行 pid / start / path
# 離開碼：0 = 空閒（n=0）｜1 = 有人在跑｜2 = 量不到（powershell 不在）★2 不是「空閒」
command -v powershell.exe >/dev/null 2>&1 || { echo "GODOT-BUSY n=? (powershell.exe not found)"; exit 2; }
out="$(PSExecutionPolicyPreference=Bypass powershell.exe -NoProfile -Command "\$g = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { \$_.Name -like 'Godot_v*' }); Write-Output ('GODOT-BUSY n=' + \$g.Count); foreach (\$p in \$g) { \$c = \$p.CommandLine; if (\$c -and \$c.Length -gt 120) { \$c = \$c.Substring(0,120) }; Write-Output ('  pid=' + \$p.ProcessId + ' start=' + \$p.CreationDate + ' ' + \$c) }" 2>/dev/null)"
[ -z "$out" ] && { echo "GODOT-BUSY n=? (query produced nothing)"; exit 2; }
echo "$out"
n="$(printf '%s' "$out" | sed -n 's/^GODOT-BUSY n=\([0-9][0-9]*\).*/\1/p' | head -1)"
[ -z "$n" ] && exit 2
[ "$n" = "0" ] && exit 0
exit 1
