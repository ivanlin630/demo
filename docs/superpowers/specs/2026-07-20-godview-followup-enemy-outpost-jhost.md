# spec：god-view follow-up — enemy_outpost + jhost belief-gate（detector 撿的 2 殘留）

> 層級：L3（2 site belief-gate，jhost trivial + enemy_outpost 1 設計點）。off LOCAL main。
> 來源：constitution_gate v3 god-view detector（f7ff2ea0）機器證撿；reviewer R² 判**兩者皆真 leak**（半公共/需知位 REFUTED，Slice C 已裁 infra 位需 belief）。arc 非 literally-zero 的收尾。

## leak 2 site（reviewer 確認）

### ① decision_context.gd::gather `:373` — jhost live pos（trivial，同 1119）
```gdscript
var _reachable: bool = not PathSystem.find_path(state, team.tile_pos, state.teams[_jhost].tile_pos).path.is_empty()
```
`_jhost`=strong_neighbor(cross-faction 時)/consolidate_target。cross-faction 讀 jhost live pos=god-view，**同 1119 can_reach 類**。

**修（同 1119/Slice D belief_pos 範式）**：
```gdscript
var _jpos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, _jhost)
var _reachable: bool = _jpos != Vector2i(-1, -1) \
    and not PathSystem.find_path(state, team.tile_pos, _jpos).path.is_empty()
```
- 無 belief（positionless/斷視線太舊）→ `_jpos==(-1,-1)` → `_reachable=false`（不知對方在哪=無法算 join 可達，合 null-belief-flee 精神）。
- `team.tile_pos`=自身（god-view 自己合法），不動。

### ② faction_ai_system.gd::_enemy_outpost_positions `:2912-2921` — 全圖敵據點 live（1 設計點）
```gdscript
for tile_id in state.world.tiles:
    ... if tile.outpost_level == 0: continue
    var owner = state.teams.get(tile.outpost_owner)
    ... if owner.faction_id == leader_team.faction_id: continue
    out.append(tile.tile_pos)   # ← 全敵據點位置=瞬知全敵基建
```
用途：`_evaluate_new_outpost_location:2851-2855` **軟 penalty**（建址距最近敵據點 <5 → 減分；非硬排除）。god-view 效果=避開**全部**敵據點含未見。

**修（belief-gate，★store-free：belief-about-owner proxy）**：
```gdscript
    # belief-gate：只納「觀察者對 owner team 有 belief(見過/聞得)」的敵據點——復用 best_estimate,無新 store
    if BeliefSystem.belief_pos(state, leader_team.team_id, owner.team_id) == Vector2i(-1, -1): continue
    out.append(tile.tile_pos)
```
- 語意：**知道對方存在(見過該敵隊)才避其據點**；全未知敵據點不避 → 有時建 near 未見敵 → 更多衝突湧現（合鐵律，arguably 更佳 emergence）。
- **★設計點（R² vet）**：belief-about-owner=**imperfect proxy**（belief_pos 給 owner 隊 last-seen 位非據點位；owner 可能 roam，見過 owner≠知據點位）。但：①store-free（不建 team_outpost_known 大 store，避 Slice C 級重工）②「避已知敵」語意合理③軟 penalty 非硬排除，容忍度高。**替代**=建 `team_outpost_known` sighting store（vision/relay 三源，同 team_market_known）——**過重**（軟 penalty 不值），故取 proxy。R² 判 proxy 可接受 vs 需真 store。

## 驗收
- **TDD**：①jhost 可見→belief 位算可達/斷視線 recent→last-seen/positionless→(-1,-1)→不可達。②enemy_outpost：owner 有 belief→納入避讓/owner 無 belief→不納（未見敵不避）。
- **gate** PASS（★constitution_gate v3：這 2 site 修後 gv_teamstate/gv_mapscan fingerprint drop→removed=PASS，baseline 該 2 CANDIDATE-LEAK 註行移除）/ **headless** 0 new / **determinism** 2 跑 byte-identical（無新 RNG）。
- **★measure（→measurer，behavior-sensitive）**：enemy_outpost belief-gate 影響選址→outpost 分佈/衝突率/doom-delta（seed1337/42）；jhost 影響 join 決策（輕）。doom-delta 惡化不明顯即 OK（arguably 更多衝突=更好戲，藍圖看數字）。

## arc 收尾
2 site merged + baseline drop 2 CANDIDATE-LEAK 註 → **god-view detector gv_teamstate/gv_mapscan 剩全 legit/gray** → 真 zero-untracked-god-view-residual → 報 blueprint arc 收官 → economy arc（re-baseline）。

## 排序
L3，off LOCAL main。R²（★enemy_outpost proxy vs 真 store 設計點 + jhost 範式一致）→ dispatch。可與 1119 同批或緊接（jhost 完全同 1119 範式）。
