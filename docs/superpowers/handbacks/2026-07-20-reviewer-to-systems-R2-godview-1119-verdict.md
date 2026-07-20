---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·god-view 1119 can_reach·CLEAN] root 坐實(can_reach:1120 讀 live 距,force_ge_target:1113 用 belief=不一致)。修=belief-gate 距離同 Slice D position 範式(可見 live/斷視線 last-seen/positionless→false)。①範式一致(distance=位置無 velocity 錯配更單純)②positionless→false 合 null-belief-flee/dist_factor③vacuous(<999 恆真)不擴刀對=god-view 純度 vs reachability 語意分開,vacuous 另記 known_issues 我認可④無 RNG。CLEAN→dispatch=arc 收尾。"
---

# R² verdict：god-view 1119 can_reach（便宜收尾）

**VERDICT: CLEAN** — 可 dispatch。`premise_contradiction: false`。便宜、乾淨、與 god-view arc 範式一致。factcheck 對 HEAD `b5f9efa0`。

## Root 坐實
`can_reach`（`faction_ai_system.gd:1119-1120`）：`_hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` = **讀 live target 位算距**。周圍 `force_ge_target:1113` 用 `BeliefSystem.best_estimate`（belief armed_est）→ **同 func 內 belief/live 不一致**（spec 觀察對）。god-view leak 坐實。

## 審點逐一
1. **belief-gate 範式一致 → CLEAN**。修=distance target 位走 belief（可見 last_tick==current→live 距 / 斷視線→belief last-seen 距 / positionless→false）= **同 Slice D position 態範式**。★**比 D 更單純**：can_reach 是**距離（位置）計算，非 velocity**→無 D 的 velocity-vs-position 錯配風險（last-seen 位算距離有意義，不像 velocity 需兩連續觀測）。乾淨套用。
2. **positionless→false → CLEAN**。無 belief 位=無法算可達→false（不瞬鎖真位當可達）。合 null-belief-flee「無座標→不 act」+ dist_factor「positionless→0」精神。sound。
3. **★vacuous 不擴刀 → CLEAN（scope 紀律對）**。`<999` 近-vacuous（hex 距恆 << 999→恆真=can_reach 從不真 gate=以為任 target 可達即攻/追、PathSystem 真可達性沒查）**是真決策品質洞、值得 known_issues 另票**（我認可 systems 判）。但**本刀只治 god-view read（belief-gate）**——god-view 純度（不讀 live）vs reachability 語意（<999 有無意義）= **兩不同 concern，正確分開**。別把 god-view fix scope-creep 成 reachability-語意 fix。同意。
4. **無新 RNG → CLEAN**。belief best_estimate/belief_pos 純讀。

## 回覆
CLEAN → dispatch implementer（belief-gate can_reach 距離 + positionless→false）。impl pre-merge R² 重點：①can_reach 距離走 belief（可見 live/斷視線 last-seen/positionless→false）無殘 live `state.teams[target_id].tile_pos` ②無新 RNG ③vacuous `<999` 不動（另 known_issues）。

——**此條 merged → god-view belief-化 arc 全 leak 治完**（A/F/E/D/B/C + null-belief-flee + 1119）→ constitution_gate 擴版（god-view detector）證零殘留 → economy arc。arc 收尾一條乾淨小刀，範式一致。
