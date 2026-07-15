---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH·主arc] 位置感知belief化(god-view位置根治)——新分支feat/position-belief;R²v2 CLEAN(異質框外審+2輪收斂);真wire=to_task+movement;TDD"
---

# Dispatch：位置感知 belief 化（god-view 位置根治，主 arc）

spec（★讀全文 v2，含重定靶+8 缺口）：`docs/superpowers/specs/2026-07-15-position-belief.md`
R²v2 CLEAN：`2026-07-15-reviewer-to-systems-position-belief-r2v2-clean.md`（異質框外審+2 輪標準收斂，大框慎重）。

## 在哪：新分支
`feat/position-belief`，base 最新 origin/main（`e32a5fee`+，含 diplomacy merged）。

## ★真 wire（v1 瞄錯靶被框外審抓，v2 重定靶——做這些，非 decision_context 死欄位）
- **Fix A `belief_pos` helper**：belief last-seen tile_pos + **staleness gate**（last_tick 超 `BELIEF_STALE_TICKS` TEST VALUE→視同未知）；**★無 belief/過期→回 (-1,-1)，禁退自身**（`_refresh_attack_pursuit` 的活值 fallback 不照抄）。
- **Fix B `options.gd` to_task 8 分支**（:192/198/204/211/220/230/237/242）`state.teams[id].tile_pos`→依目標類型：
  - 跨-faction 敵/社交（掠奪/攻擊/外交/JOIN strong_neighbor）→ `belief_pos`；(-1,-1)→回 IDLE 撲空。
  - **JOIN host 兩源分流**：`strong_neighbor if !=-1 else consolidate_target`；strong→belief_pos，**consolidate（同-faction）→ `known_member_states.tile_pos`**。
  - **佔村→outpost tile 靜態座標**（打村格非空地，belief 會打空地）。
  - **徵收/同-faction→`known_member_states.tile_pos`**（`world_state:417`，非 belief）。
- **Fix C `movement_system.gd:37-56`** ESCORT/MERGE/JOIN 逐 tick `move_target=target.tile_pos`→`belief_pos`（視野內跟上/斷線撲空/同-faction MERGE 走 known_member_states）；(-1,-1)→保持或 release，不退自身。
- **Fix D `_nearest_independent`** 補 has_belief gate（現無，用活值距離選）。
- **Fix E（次要）** observe_velocity visible 綁親見 claim（或接受幾何不對稱，你判）+ `path_system:29/170-171` 契約註解改寫。

## 硬約束（框外審抓的，別重犯）
1. **fallback 禁退自身**（無 belief→(-1,-1)→caller 棄；退自身=catch-up 恆追上/threat 幽靈貼臉，更糟）。
2. **staleness 必配**（belief 位置讀 last_tick，過期視同未知，防永久 threat loop）。
3. **通道選對**：跨-faction→belief_pos；同-faction→known_member_states；靜態設施(outpost)→tile 真值；自身位置→真值。
4. **憲法零新 try_set**（改位置資料來源，不加判斷器）。

## TDD
1. target 斷視線+移動→追兵 move 到 last-seen→**撲空**（逃脫）。
2. target belief 過期→threat_react 歸零（不永久 loop）。
3. 無 belief target→option 不評估/撲空 release，**無隊移向自身座標**。
4. 佔村→打**村格**（outpost tile 非空地）；徵收/同-faction→找到同僚（known_member_states）。
5. 標準：**同 seed 兩跑 bit-identical**（非 baseline byte-identical，行為本就該變）；憲法 sites=29；headless 零新增。

## 完成後
→ measurer 中性世界（★逃脫故事：追兵撲空率>0 + staleness 解 loop + 不誤殺）→ QA 故事複判 → blueprint 批 merge。
scope 疑義/前提 gap 走 `to:systems`（不自標 REDO、不自更 baseline）。
