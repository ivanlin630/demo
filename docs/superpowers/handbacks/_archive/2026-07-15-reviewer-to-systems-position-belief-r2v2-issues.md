---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·issues] 位置belief化v2——重定靶/8缺口7項全收斂驗證通過,但Fix B的JOIN(併入)漏做tribute同款的跨/同faction通道分流(consolidate_target同faction卻被歸cross-faction belief_pos)"
---

# R② 判決（v2 重定靶後）：位置感知 belief 化

verdict: **issues**
premise_contradiction: false

## 真 wire 重定靶驗證（file:line 全查證）

`options.gd` 8 分支逐一核對，行號與內容精確吻合 v2 spec：`:192`(掠奪)/`:198`(佔村)/`:204`(併入=JOIN)/`:211`(吸納=MERGE)/`:220`(乞食=BEG)/`:230`(攻擊)/`:237`(徵收)/`:242`(外交)——確認這些才是真正驅動移動的活值讀取，v1 瞄錯靶的診斷屬實，v2 重新定靶正確。`_nearest_independent`(`faction_ai_system.gd:2096`) 確認無 belief gate（Fix D 標的成立）。

## 7 項缺口收斂複核

1. **重定靶**：CLEAN（上述核對）。
2. **movement_system 明文裁定**：Fix C 明寫視野內跟上/斷線撲空/同-faction 走 known_member_states，三態齊全，CLEAN。
3. **#7 佔村定案**：Fix B 明寫「用 outpost tile 靜態座標」，不留二選一，CLEAN。
4. **#12 徵收通道**：Fix B 明寫讀 `known_member_states.tile_pos`，非 BeliefSystem，CLEAN。
5. **staleness gate**：Fix A `_claim_too_old`（讀 `last_tick`）超 `BELIEF_STALE_TICKS` 視同未知→`(-1,-1)`，解永久 loop 風險，CLEAN。
6. **fallback 鐵則**：Fix A 明寫「無 belief/過期→回 `(-1,-1)`，caller 棄，禁退自身」，且明文點名不照抄 `_refresh_attack_pursuit:291` 的活值 fallback，CLEAN。
7. **has_belief gate 補齊**：Fix D 要求補 gate 或明示通道，CLEAN（設計方向對，實作細節可留 implementer）。
8. **驗收措辭**：改「同 seed 兩跑 bit-identical」，CLEAN。

## issue：Fix B 的 JOIN（併入）漏做 tribute 同款的跨/同 faction 通道分流

`options.gd:200-205`「併入」的 host 選擇：`host = strong_neighbor_id if strong_neighbor_id != -1 else consolidate_target_id`——`consolidate_target_id` 明確是**同 faction**（`:200` 註解「無則 consolidate_target(同faction)」，且是本 session 稍早 Fix A-2 併入審查時已核實的既有邏輯）。

v2 Fix B 把「併入 JOIN 投靠」一律歸類進「跨-faction 敵情/社交目標→belief_pos」那條，**沒有像處理 #12 徵收那樣，替 JOIN 的 `consolidate_target_id`（同 faction）分支切到 `known_member_states` 通道**。而 Fix C（movement_system 逐 tick 追蹤）反而正確處理了這個區分（`:41`「同-faction MERGE（吸納/consolidate）→known_member_states」）——**Fix B 與 Fix C 對同一組同-faction 目標的通道選擇不一致**。

**後果**（比 v1 的「god-view 洩漏」溫和，但仍是回歸）：同 faction 內部的整併 host，若發起隊從沒親眼見過該同僚（belief 無 claim，同 #12 分析的理由——faction 內部遠端同僚常見不到面），Fix B 用 `belief_pos` 會頻繁拿到 `(-1,-1)` → JOIN 撲空/不派工 → **合理的同-faction 整併路徑被誤傷**（明明 `known_member_states` 有這個同僚的新鮮位置資料，卻沒被用上）。

**要求**：Fix B「併入」分支比照 #12 徵收 + Fix C 的處理方式——按 `host` 實際來源分流：`host==strong_neighbor_id`（跨 faction）→ `belief_pos`；`host==consolidate_target_id`（同 faction）→ `known_member_states.tile_pos`。一致性修正，非新設計，一行 spec 補充即可。

## 框外審評估
方向已在 v1 輪過異質框外審驗證，v2 是在已認同架構上精確重定靶——不需再升異質，標準複核已足夠抓出這個具體不一致。

## 結論
真 wire 重定靶正確、7/8 缺口全收斂。**唯一 issue＝Fix B 的 JOIN 分支對同-faction host 通道選擇跟 Fix C/#12 不一致**，會誤傷合理的同-faction 整併路徑。**issues → halt，退回一行補充分流邏輯後可 CLEAN**（非重新設計）。
