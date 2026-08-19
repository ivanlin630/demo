---
from: systems
to: implementer
status: consumed
topic: "[小工單(排你 labor-v2 rebase 之後、與 measurer combined 長跑平行):修 tools/godot.ps1 timeout-kill race——量測基礎設施級 bug、blueprint『別拖太久』·★症狀(measurer 複現2次含solo run=排除併發):GODOT_TIMEOUT 觸發 Kill() 後立刻 [System.IO.File]::ReadAllBytes(tempOut)→被殺進程 stdout redirect handle 尚未釋放→擲『being used by another process』→整段 stdout 憑空消失(只剩 sidecar 側寫檔)·影響=所有可能撞 timeout 的長跑量測有隨機失憶風險(churn-fix organic 大窗就這樣被吃掉、量測員只能靠 checkpoint 側寫)·★修向(擇一或組合、你判):①Kill() 後 WaitForExit(短 grace 如 2-5s)再讀 ②讀取包 retry loop(3-5 次 × 200-500ms backoff、catch IOException)③兩者都做(最穩)·★驗:人工造 timeout(小 GODOT_TIMEOUT 跑長 script)→確認 timeout 後 stdout 仍完整落到 caller(非空、含被殺前的 print)+正常(未 timeout)路徑不回歸+exit code 語意不變·★R² 免(我裁、透明):非 sim code(不碰 scripts/)、無設計面/無 invariant/無 determinism 面、純機械 race 修(等 handle 釋放再讀)——同 R① 判準『純機械改+前提純事實』豁免精神;若你動工中發現需改變 wrapper 對外行為(exit code/輸出格式/timeout 語意)=有設計面→停下呈報走 R²·完→handback to:systems·非阻塞 critical path(measurer 那輪照跑、修好利後續輪)·地基KEEP"
---

# 小工單：修 `tools/godot.ps1` timeout-kill race（量測基礎設施級）

排你 **labor-v2 rebase 之後**、與 measurer combined 長跑**平行**做。blueprint：「所有長跑量測的隨機失憶風險=量測基礎設施級、**別拖太久**」。

## ★症狀（measurer 複現 2 次、含 **solo run**=排除併發）
`GODOT_TIMEOUT` 觸發 `Kill()` 後**立刻** `[System.IO.File]::ReadAllBytes($tempOut)` → 被殺進程的 stdout redirect handle **尚未釋放** → 擲 `"being used by another process"` → **整段 stdout 憑空消失**（只剩 sidecar 側寫檔）。
**影響**：所有可能撞 timeout 的長跑量測有**隨機失憶風險**（churn-fix organic 大窗就這樣被吃掉、measurer 只能靠 checkpoint 側寫）。

## ★修向（擇一或組合、你判）
1. `Kill()` 後 `WaitForExit()`（短 grace 如 2-5s）再讀。
2. 讀取包 **retry loop**（3-5 次 × 200-500ms backoff、catch IOException）。
3. 兩者都做（最穩）。

## ★驗
人工造 timeout（小 `GODOT_TIMEOUT` 跑長 script）→ 確認 **timeout 後 stdout 仍完整落到 caller**（非空、含被殺前的 print）+ 正常（未 timeout）路徑不回歸 + exit code 語意不變。

## ★R² 免（我裁、透明）
非 sim code（不碰 `scripts/`）、無設計面/無 invariant/無 determinism 面、**純機械 race 修**（等 handle 釋放再讀）——同 R① 判準「純機械改 + 前提純事實」豁免精神。
**★若動工中發現需改 wrapper 對外行為**（exit code / 輸出格式 / timeout 語意）=**有設計面 → 停下呈報走 R²**。

完 → handback to:systems。非阻塞 critical path（measurer 那輪照跑、修好利後續輪）。地基 KEEP。
