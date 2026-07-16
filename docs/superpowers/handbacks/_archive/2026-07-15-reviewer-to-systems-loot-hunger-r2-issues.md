---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·issues] 絕境掠奪對準糧源——真根/感知鐵律/②c血訓/不誤傷皆CLEAN,但spec留兩案模糊(連續權重vs雙鍵切主序)未收斂,後者恐違身分=權重"
---

# R② 判決：絕境掠奪對準糧源（hunger-weighted prey）

verdict: **issues**
premise_contradiction: false

## 逐點驗（file:line 全查證）

1. **真根對（target vs yield）CLEAN**：`npc_combat_system.gd:550-559 _loot_resources` 確認 food 在 `for res in [...]` 首位、按 `effective_loot` 比例搶（`:555 taken = loser.resources.get(res,0)*effective_loot`）——**target 若無糧，food taken 恆為 0**（`:556 if taken<=0: continue`），故 yield 機制本身沒問題，問題出在挑到的 target 有沒有糧。`faction_ai_system.gd _find_weakest_prey`：主序 `pop_est`（beatability），`food_est` 僅 `PREY_POP_TIE_EPS=0.5`(`:35`) 帶內 tie-break——確認絕境 looter 不優先鎖糧多目標。真根診斷＝target 選擇，非 yield，坐實。
2. **感知鐵律 CLEAN**：`_find_weakest_prey` 已用 `BeliefSystem.best_estimate` 讀 `food_est`（belief，可失真），非 god-view 讀真值——延續既有模式，非新違反。
3. **不誤傷 strategic raid CLEAN（設計上）**：spec 明寫 sated looter（`food_days >= DESPERATION_DAYS`，`terms.gd:6 DESPERATION_DAYS=3.0` 核實）現行 pop_est 為主序不變，前提是實作正確收斂在 sated 端權重→0（見下 issue）。
4. **不違 ②c 血訓 CLEAN**：spec 只加權 food_est、不新增 food 硬濾（無糧目標仍在候選内，只是排序靠後），設計上未重犯 ②c 濾掉即崩的錯誤。
5. **殘留 thrash 診斷合理**（待 measurer 實證，非 code 可靜態驗證）：搶到糧解飢→不再重觸求生決策→震盪源消，因果鏈站得住，但最終要中性世界數字驗，非本輪 blocker。

## issue：spec 留兩案模糊，其中一案恐踩「身分=權重非路徑切換」

`spec:19-22` 同時列出兩種實作方向給 implementer 自選：
- (a) 「`prey_score = beatability_term − food_gap_penalty`」——連續加權，飢餓度平滑調 food 權重，sated→0。
- (b) 「雙鍵排序改：飢餓時 food_est 升為主序 / 不飢餓時 pop_est 為主序」——這是**在 `food_days < DESPERATION_DAYS` 門檻處離散切換排序主鍵**，本質是一個 if-branch 決定用哪個鍵當主排序，非連續權重函式。

`invariants.md:197`「身分=權重非路徑切換……任何『按身分切換決策路徑』（如 `fid≠-1 → 關掉個人層`）=違規——身分只能加權重」——雖然原文語境是 faction 身分，但精神通用：(b) 案在 `food_days` 門檻是否跨越時，讓 `_find_weakest_prey` 走完全不同的排序邏輯（主鍵互換），是**離散模式切換**而非「連續加權」，與 spec 自己引用的同一條不變量精神不一致（spec `:27` 自己也寫「身分=權重非路徑切換」但 `:19-22` 卻把違反精神的 (b) 案並列成可選項）。

**要求**：spec 收斂成單一設計——**只採 (a) 連續加權公式**（`prey_score` 型，food 權重＝`food_days` 的連續函式，sated 精確收斂到現行 pop_est-only 行為），**刪除 (b) 雙鍵切主序選項**，不留給 implementer 挑，避免在一個 invariant 敏感的設計點上留模糊地帶。

## 框外審評估
同意——既有 finder 排序改（continuation），非新框，標準審足夠。

## 結論
真根/感知鐵律/②c 血訓/不誤傷四點 CLEAN。**唯一 issue＝(a)/(b) 二選一未收斂**，(b) 恐踩身分=權重不變量精神。**要求 spec 收斂為單一連續加權公式**（刪除雙鍵切主序選項）。**issues → halt，退回一行收斂後可 CLEAN**（非重新設計，方向已對）。
