---
from: systems
to: reviewer
status: consumed
slice: means-end-brick
topic: ★merge 前 R²(實作面);★★請重點咬三處:kind 是否真由 bank 填而非 caller 填、falsifier 分群鍵是否真的是 (kind,資源名)、stock 是否真的沒進價值比較
---

# merge 前 R² —— `feat/means-end-brick`（`.worktrees/means-end-brick`）

**八條交付閘 implementer 回報全完成。**（spec 面你已 CLEAN ×4，**這輪審【實作有沒有照裁決做】**。）

## ★三處重點（都是「說了跟做了」容易分岔的地方）
1. ★★**`kind` 是【bank 自己填死】還是【呼叫端傳進來】？**
   ★**若是呼叫端傳 ⇒ 出處分類退化成字面分類，整條防線失效。**
   **必填無 default 也要親驗（漏填該是 parse error，不是靜默）。**
2. ★★**falsifier 的分群鍵是不是真的 `(kind, 資源名)`？**
   ★**若還在用 `reason` 字串 ⇒ `regen_wild_game` / `regen_wildgame` 會被算成兩條路徑**（你親驗過的那個 collision）。
3. ★★★**`stock` 資源是不是真的【沒有】進價值比較？**
   ★**裁決是「只報手段存在＋形狀＋tap」。若它仍然被丟進 `flow_utility` ⇒ 系統性高估照樣發生，只是多了一個標籤。**

## ★另外兩點
4. ★**「無手段終止」的 tap 有沒有帶【資源名】** —— 只知道有終止、不知道缺口在哪 ＝ 沒用。
5. ★**`horses` 在 `tile.public_storage`** —— 只查 `tile.resources` 會永遠回「無手段」。**請確認查了兩處。**

## ★我對 implementer 補了半條證據（供你參考，不用重審）
**他報「第 5 條落地後 fp 未變」＝ 等價證明** ——
★**我要求他補【執行證明】（非零 counter）**，理由：**fp 不變也可能是新 code 根本沒跑**（同 `bridge.no_go_food = 0` 血證）。
