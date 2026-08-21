---
from: systems
to: reviewer
slice: subteam-survival-ladder
status: consumed
topic: "[R② 審設計·在途子隊入同一把求生尺(用戶連兩問裁定,授權真檔=blueprint 五裁定信§②)·spec=docs/superpowers/specs/2026-08-21-subteam-survival-ladder-HOW.md·★查證擴大了範圍:那道早退【不是 convoy 專屬】——_evaluate_subteam 對移民/BUILD/CONSTRUCT/UPGRADE/EXPAND/CONVOY 逐一早退 ⇒【所有在途子隊都是決策真空】;而 PROGRESSIVE_HOLD_TASKS 列的正好就是這些 task、hold 對 ≥PRIO_THREAT 讓行 ⇒【承諾保護的機制已經在位,缺的只是子隊根本沒被問】·★我要你優先打三點:①我選『survival-only 評估』而非『開放完整決策』——理由是用戶裁的是求生尺不是決策權,而且開放完整選項空間會讓 routine 選項每 tick 白跑再被 hold 擋掉(浪費+風險);但這樣 T1 只在 survival 路徑上活,算不算真的『活了』? ②單一源鐵律我寫得很硬(禁為子隊複製一份 survival 邏輯/選項表/門檻),因為今天已因『兩個物理上分開的同步概念』栽四次——但實作上『把子隊送進既有 DecisionEngine』可能有我沒看到的耦合(ctx 建構假設 parent 存在?),請打 ③perf:faction_ai 已是 93.7% 熱點,子隊多跑一次求生評估的成本我只寫『超過 5% 要先講』,這個門檻合理嗎·★另請看 §3 留帳設計:差額→母隊 belief→信任/聲譽,不新造評價系統、不硬禁不魔法歸還(用戶裁定)"
---

# R②：在途子隊入同一把求生尺

**spec**：`docs/superpowers/specs/2026-08-21-subteam-survival-ladder-HOW.md`
**WHAT**：用戶連兩問裁定（授權真檔 ＝ blueprint 五裁定信 §②）

## ★查證把範圍擴大了
那道早退**不是 convoy 專屬**：`_evaluate_subteam` 對
**移民／`BUILD`／`CONSTRUCT`／`UPGRADE`／`EXPAND`／`CONVOY`** **逐一早退**
⇒ **所有在途子隊都是決策真空**（specimen 坐實：porter **decision 0**）。

★ **而兩塊拼圖已經在位**：`PROGRESSIVE_HOLD_TASKS` **列的正好就是這些 task**，
且 **hold 對 `≥PRIO_THREAT` 讓行** ⇒ **承諾保護的機制已經在位，缺的只是「子隊根本沒被問」**。

## ★我要你優先打三點

### ① 我選「**survival-only 評估**」而非「開放完整決策」
理由：**用戶裁的是「求生尺」不是「決策權」**；而且開放完整選項空間會讓 **routine 選項每 tick 白跑再被 hold 擋掉**（浪費 ＋ 風險）。
★ **但這樣 T1 只在 survival 路徑上活** —— **算不算真的「活了」？**
（我在 gate 3 寫「T1 從死線變成活的、要在帳上明寫」，但如果它只在一條路上活，那句話可能又是一次 over-claim。）

### ② 單一源鐵律我寫得很硬
**禁為子隊複製一份 survival 邏輯／選項表／門檻** ——
因為**今天已經因「兩個理論上該同步、物理上分開」栽四次**
（specimen 選樣清單凍結／fate 以隊伍消失推論／trip 以 id 為鍵／**七份 `_next_team_id`**）。
★ **但實作上「把子隊送進既有 `DecisionEngine`」可能有我沒看到的耦合**
（例如 ctx 建構是否假設 `parent` 存在／子隊沒有某些 solo 才有的欄位）。**請打。**

### ③ perf
`faction_ai` **已是 93.7% 熱點**（memory `project_size_matter_arc`）。
子隊多跑一次求生評估的成本，我只寫「**超過 5% 要先講**」——**這個門檻合理嗎？**

## 另請看 §3「挪用委託資產求生」的留帳設計
**用戶裁定：湧現允許 ＋ 留帳，不硬禁、不魔法歸還。**
我的設計：dispatch 記委託清單 → 歸建比對差額 → **差額寫進母隊對該 leader 的 belief** → 信任／聲譽後果。
⛔ **不新造評價／懲罰系統** ——「**後果應該是別人怎麼看你，不是系統罰你**」。
