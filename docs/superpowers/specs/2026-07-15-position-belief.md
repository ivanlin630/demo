# Spec：位置感知 belief 化（god-view 位置根治，感知腳最後大洞）

status: draft（待 reviewer R②【升異質框外審】CLEAN → dispatch implementer）
owner: systems
premise_verified: 12 god-view 位置點 file:line 坐實（結構稽核維度③）；belief 已存 last-seen 位置坐實
blueprint_intent: `2026-07-15-blueprint-to-systems-godview-position-arc.md`（逃得掉/躲得住/伏得成）
frame_challenge: ★大框（redirect 大量工作、structural、難逆）→ **R② 升異質框外審**（別 Opus 代 + refute-first，確認位置 belief 化不誤殺該讀真值處）
governing: `game-design.md §決策模型`（感知腳）+ `invariants.md §感知鐵律`（只吃可見/最後可見，非 god-view 現址）

## 一句話
選敵「打誰/多弱/多富」已 belief 化守鐵律，**唯目標「在哪」+「追不追得上」讀活體真值**（12 點）——「一旦發現過→對方現址永久零延遲零迷霧可讀」→ 躲森林/繞路/斷後撤退全無效，追兵永遠精準攔截。修＝**位置感知走 belief last-seen**（追最後看到的位置；斷視線+移動→跟丟撲空）。**belief 已存 last-seen 位置（`vision_system.gd:113 tile_pos`+`:114 last_tick`），決策層改讀它。**

## 正確樣板已存在（鏡射它，非發明）
`faction_ai_system.gd:291 _refresh_attack_pursuit` 是**唯一守鐵律的位置消費**：
```
last_pos = BeliefSystem.best_estimate(state, team, target).get("tile_pos", <fallback>)
predicted = PathSystem.predict_intercept(state, team, target)   # 視野外退 belief last_pos
move_target = predicted if predicted != <live> else last_pos
```
**本刀＝把這個「讀 belief last-seen 位置」樣板推廣到其餘 11 點**（現全讀 `state.teams[X].tile_pos` 活值）。

## Fix：12 點逐一（讀活值 → belief last-seen）
**判準**：目標是**別隊**（追/攻/投靠/施援/威脅源）的位置 → belief last-seen；**自身位置**（`self.tile_pos`）→ 照讀真值（自己不靠情報，OK）。

| # | file:line | 現讀 | 改 | 嚴重 |
|---|---|---|---|---|
| 1 | `path_system.gd:204` estimate_catch_up | `target.tile_pos` 活值做 reachability/ETA | 用 belief last-seen tile_pos（追丟＝撲空） | ★★★ |
| 2 | `path_system.gd:176,181` observe_velocity | `trusted=true→visible 恒真`（曾發現即可見） | visible＝**當下距離≤vision**（真在視野才刷速度/位置） | ★★★ |
| 3 | `path_system.gd:223-224` _is_moving_away_observed | `target.tile_pos` 活值 | belief last-seen | ★★★ |
| 4 | `threat_assessment.gd:20` | `_hex_dist(self, other.tile_pos)` other 活值 | other → belief last-seen（self 留活值） | ★★ |
| 5 | `threat_assessment.gd:33` future_pos | `other.tile_pos + dir` 活值 | belief last-seen + dir | ★★ |
| 6 | `decision_context.gd:184` weak_prey_pos | `state.teams[prey].tile_pos` | belief last-seen | ★★★ |
| 7 | `decision_context.gd:192` occupy_target_pos | 活值 | belief last-seen（佔村目標＝outpost tile 靜態，見註） | ★★ |
| 8 | `decision_context.gd:178` threat_pos | 活值 | belief last-seen | ★★ |
| 9 | `decision_context.gd:198` strong_neighbor_pos | 活值 | belief last-seen | ★★ |
| 10 | `decision_context.gd:209` aid_target_pos | 活值 | belief last-seen | ★ |
| 11 | `decision_context.gd:283,310` intent_target_pos | `state.teams[...].tile_pos` | belief last-seen | ★★★ |
| 12 | `decision_context.gd:261,266,270` faction attack/tribute/diplo _pos | 活值 | belief last-seen（攻擊；徵收=同 faction 較不算敵，見註） | ★★/★ |

**共用 helper（消 12 點重複）**：加 `_belief_pos(state, observer, target_id) -> Vector2i`＝`best_estimate().get("tile_pos", <last-known/自身 fallback>)`，12 點全走它（鏡射 `_refresh_attack_pursuit` 邏輯，含 predict_intercept 視野外退 belief）。

## ★不誤殺（R② 框外審重點驗）
- **自身位置**（`self.tile_pos`/`team.tile_pos` 做起點/自我狀態）→ **照讀真值**（自己不靠情報）。只有「別隊目標位置」改 belief。
- **靜態設施位置**（outpost/tile/farmable）→ 是**世界固定物理**非隊的瞬時位置，照讀真值（#7 佔村目標=outpost tile 靜態，belief 只需知「哪個 outpost」非追它移動；implementer 判該不該走 belief 或直接 tile——outpost 不會跑）。
- **同 faction 目標**（#12 徵收/內部 herald）→ 較不算敵情，可留活值 or belief（implementer/藍圖判；感知鐵律主為敵情）。
- **belief fallback**：目標從沒見過（無 belief）→ 選敵 finder 已 gate `has_belief`（選不到無情報目標），故 `_belief_pos` 恒有 last-seen 可退；真無則 fallback 自身/(-1,-1) 安全值。

## invariant 守
- **感知鐵律位置版**：目標位置只吃可見/最後可見，禁 god-view 現址。
- **determinism**：belief 讀純確定性；observe_velocity visible 改「當下距離≤vision」仍確定（`suppress_observe_noise` 旗標另管 randf，本刀不碰）。
- **憲法**：不加行為判斷器；改的是位置**資料來源**（活值→belief），決策邏輯不變。
- **不動觀測 confound 修**（suppress_observe_noise 那套）。

## 驗收法（★中性世界 + 故事 QA）
1. **★逃脫故事出現（headline）**：斷視線+移動的隊，追兵**撲空率 > 0**（現＝0 永遠攔截）。specimen trace：追擊 target 讀 last-seen、視野內才刷新；追丟→belief 過時→move 到空位撲空。
2. **belief 位置驅動**：finder reachability + ctx `*_pos` 讀 belief last-seen（非活值）；observe_velocity visible＝當下距離≤vision。
3. **不誤殺**：自身位置/靜態設施照讀真值（自己不靠情報，outpost 不跑）；抽驗自身移動/佔村不因誤 belief 化而壞。
4. **無回歸**：determinism byte-identical（belief 確定）；憲法 sites 不變；HOB obey%；sanity 零新增。
5. **中性世界判**（confound 已修）。

## dispatch 註（R② 升異質框外審 CLEAN 後）
- 新分支 `feat/position-belief`，base 最新 main。
- **★R② 升異質框外審**（大結構框，redirect 12 點+難逆）：refute-first 驗——(a) 哪些點該留活值（自身/靜態設施）被誤 belief 化了嗎? (b) belief fallback 安全（無 belief 退什麼）? (c) observe_velocity visible 改「當下距離」會不會壞既有 threat/intercept? (d) determinism 保? (e) 有沒有漏的 god-view 位置點（12 點外）?
- 完成判定 = systems + reviewer/QA + measurer 中性驗（逃脫故事）。implementer TDD：構「target 斷視線移動」斷言追兵去 last-seen 撲空；「自身移動」斷言照真值；「outpost 佔村」斷言不壞。
