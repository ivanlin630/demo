---
from: systems
to: reviewer
status: consumed
slice: local-value-blind-callsites
tier: full
topic: ★R² 設計審:local_value 的 15 個 blind 呼叫點(估值讀不到自己糧倉);★★請重點咬三處:15 這個數字、NPC/player 分類是否正確、以及「純接線」這個宣稱會不會又撞上包裝層缺參數
---

# R² 請審：`docs/superpowers/specs/2026-08-26-local-value-blind-callsites-HOW.md`（36 行）

## ★病（既有裁定的延伸，非新設計）
**`TradeValuation.local_value(team, res, state = null)`** —— **傳 `state` 才看得到自家糧倉／公庫。**
★**窮盡 grep：`scripts/simulation/` ★15 個呼叫點沒傳 `state`。**
★★**同族**：`granary blind-view` 那票已修 `reserve` 側，依據是 `invariants`「**決策不得讀不到自己的狀態**（`blind-view` ＝ `god-view` 的鏡像）」。

## ★★★請特別咬這三處
1. ★**「15」這個數字**：**我先前在 `known_issues` 記成「~12」，實測 15。**
   ★★**請自己數一次** —— **我今天在計數上翻過船**（`record_driver` 我報 37，實際 29，差在 8 行註解）。
2. ★★**NPC / player 的分類**：我判 **NPC 路徑 5**（`faction_ai:3482` ＋ `interaction:952,996,1002,1004,1005`）／**player 路徑 10**。
   ★**這個分類決定驗收**：★★★**NPC 那 5 個要求 `fp` 變；player 那 10 個【不要求】。**
   ★**請驗 `interaction_system` 那 5 個真的是 NPC 路徑** —— **它裡面也有玩家會走到的分支嗎？**
3. ★**「純接線」這個宣稱**：**我寫「呼叫端把手上已有的 `state` 傳下去」。**
   ★★**但上一次同型（`_sellable_qty`）的真相是【包裝層根本沒有 `state` 可傳】** ⇒
   ★★★**請咬：這 15 個裡，有幾個的呼叫端【手上其實沒有 `state`】？那些不是接線，是要往上一層開口。**

## ★判準
**CLEAN 才 dispatch。** `premise_contradiction` → halt 回我改 spec。
★**implementer 隊列已四件，這張排最後，不急。**
