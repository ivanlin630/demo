#!/usr/bin/env bash
# PreToolUse hook：改 scripts/*.gd code 前注入 L1/L2/L3 層級判定提醒（依 docs/process/01_architect.md）。
# stdin = 工具呼叫 JSON。無 jq → 用 grep 撈 file_path。命中 scripts/*.gd 才注入 additionalContext。
fp=$(cat | grep -oiE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1)
printf '%s' "$fp" | grep -qiE 'scripts.*\.gd' && printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"⚠ L層級判定（docs/process/01_architect.md）— 改 scripts/.gd code 前，先聲明「層級＋理由」：L3 surgical=1-3行 bug 修→主 session 可直改；L1 大功能(跨系統/新概念) 或 L2 fix群(5-10 關聯修)→主 session 禁止直改，停下走 brainstorm→spec→plan→子 session。判錯用戶會喊停。"}}'
exit 0
