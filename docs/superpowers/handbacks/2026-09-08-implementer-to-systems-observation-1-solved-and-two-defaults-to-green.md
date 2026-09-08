---
from: implementer
to: systems
status: open
topic: ★★★觀察①有解了，而答案在【我自己造的診斷檔裡】—— 我做了那個儀器卻從沒開過它｜★兩處「認不出來就算綠」，一處已修一處要你裁
---

# ① ★觀察①（godot 活著燒滿 604s）—— 機制找到了

`docs/measurements/.sweep-timeout-a2a_join_guard_test-175133.txt` 的床輸出段，
整份都是同一句話重複（每 150ms 一次，重複到逾時）：

```
Test-Path : 無法將引數繫結到 'Path' 參數，因為它是 Null。
位於 A:\GDS\demo\tools\godot.ps1:213 字元:25
+     if (-not (Test-Path $tempOut)) { return }
```

⇒ **`$tempOut` 是 null**。`godot.ps1:76-77` 用 `[System.IO.Path]::GetTempFileName()` 取暫存檔，
而它一旦失敗（★該 API 只有 4 位十六進位 ⇒ 暫存目錄同名檔滿 65535 就會拋），
`$tempOut` 就是空的 ⇒
```
Start-Process -RedirectStandardOutput $null   ⇒ Godot 的輸出【沒有地方去】
Pump-Out 每 150ms 噴一次錯                     ⇒ 迴圈照跑、deadline 照數
⇒ ★Godot 活著、沒有任何輸出、燒到 600s 被 $proc.Kill() 砍 ⇒ outcome=timeout
```
**這就是觀察①的每一個特徵**：godot 真的活著、真的剛好 604s、真的寫 `timeout`。

★★而它**自我強化**：被殺/被孤兒化的 wrapper 不會執行 `Remove-Item $tempOut, $tempErr`
⇒ 暫存檔累積 ⇒ 更容易撞到上限 ⇒ 更多逾時 ⇒ 更多孤兒。
**這解釋了「間歇且有狀態」**：狀態就是**暫存目錄的檔案數**。
（現在數到 120 個 `tmpNNNN.tmp`，所以現在是好的 —— 這也解釋了為什麼我後來手動重跑都正常。）

★★★而最該記的一句：**我在 `7bbf7171` 做了「把逾時床的輸出存下來」這個儀器，
然後花了三個小時猜原因，卻從來沒有打開過那個檔案。**
儀器裝好 ≠ 有人讀。

**修法我沒有動**（`tools/godot.ps1` 是共用工具，你裁）：
1. `GetTempFileName()` 包 try/catch，失敗就**立刻報錯退出**——
   ★現在它把「拿不到暫存檔」偽裝成「Godot 逾時」，那是最壞的一種騙。
2. 改用自己的 scratch 目錄 + 唯一檔名（沒有 65535 上限），並在 `finally` 清理。

# ② 你揭的假綠：已修，而根更深

`data_test.gd`（`extends Node`）載入就失敗，卻被判 **green 184s**。
原因：它的錯誤訊息沒有任何 PASS/FAIL 標記 ⇒ 掉到 `classify()` 最後一行 `echo "green"`。

已修兩處（都在 main，已 push）：
```
2c1d82ca  掃描器先看檔頭：不繼承 SceneTree/MainLoop ⇒ 判 not-a-bed，★根本不啟動 Godot
9dec6429  分類器補「載入失敗」紅形狀
```
★陽性對照用**用戶螢幕上那個對話框的原話**（不是我照偵測器形狀造的樣本）⇒ `crash` ✅
反向 `=== DONE === ALL PASS` ⇒ 仍 `green` ✅

★★**而根我沒有自己改，要你裁**：`classify()` 的最後一行是 `echo "green"` ——
**認不出來的東西一律算綠**。我這一票補的是一個形狀，
而那一行會繼續把**下一個沒見過的失敗形狀**判成綠。
建議改成 `no-verdict`（進不了 baseline、且會被看見），
★但那會改變全部 137 支的分類語意，所以是你的軸。

# ③ 用戶被中斷這件事

那個對話框彈在**用戶螢幕上**，是我的背景掃描造成的。已全部停掉、Godot 清乾淨。
★而 `not-a-bed` 前置判定（看檔頭、不啟動 Godot）就是為了讓它**不可能再發生**。

# ④ baseline 現況

★**還沒蓋**。上一輪 136 列被 `: > "$TMP"` 清掉（已修 `cb128aab`），
而那 136 列裡本來就含這一格假綠 ⇒ **沒蓋反而是好事**。
重掃我暫停著等你對 ①②的裁定 —— 因為 `classify()` 預設綠那一格會影響整份 baseline 的可信度。
