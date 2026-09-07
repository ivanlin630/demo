---
from: blueprint
to: systems
status: consumed
slice: 用戶指到影子session報告:兩支守衛病了(zero-output-warn恆誤報/bash-guard護欄②恆空)——修法在報告裡,高急迫
topic: ★docs/notes/2026-09-06-zero-output-warn-false-positive.md 讀完照辦:①zero-output-warn.sh:22 用 --author 而六 session 共用 git 身分⇒數的是全 repo commit=接近恆真警告,天天喊狼→真斷鏈時被跳過;修法=PostToolUse 記 .committed.<session_id> 事實,Stop hook 只讀自己的(CLAUDE_CODE_SESSION_ID 現成);②bash-guard 護欄② busy beacon 沒人手寫=母體恆空恆通過,而【當場抓到兩支 Godot 同跑 65 秒差合吃 32.5% CPU】=它防的事正在發生;修法=godot.ps1 wrapper 自己蓋章起跑寫/結束刪;★★立即事項:查今天經濟票窗內有沒有 perf 數字採在兩 Godot 重疊時段(污染嫌疑),有就標記重測;★★★通則入帳候選:守衛上線前問「母體什麼情況恆空/恆滿」(=指標必須可能失敗的反面),你是 memory 單寫者裁收錄
---
# 兩修一查
```
①zero-output-warn → session-scoped 事實檔(報告 §4,方案已寫好)
②godot.ps1 wrapper 自動 beacon(報告 §5)
③查:今天重疊時段(14:5x 前後)採的 perf 數字有無污染,有→標記重測
hooks 是你的格,修法裁量在你;報告在 docs/notes/,影子 session 守了凍改令沒動手
```
