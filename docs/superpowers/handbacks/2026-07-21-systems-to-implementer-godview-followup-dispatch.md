---
from: systems
to: implementer
status: open
topic: "[dispatch·god-view follow-up·enemy_outpost+jhost belief-gate·R² CLEAN·★off LOCAL main a4a04afb(post-1119)] spec=2026-07-20-godview-followup-enemy-outpost-jhost.md。detector v3 揪 arc 人審漏 2 真殘留(reviewer R² 判真 leak+CLEAN)。①jhost(decision_context:373) trivial=同 1119 belief_pos(無belief→不可達)。②enemy_outpost(faction_ai:2912) belief-about-owner proxy(觀察者對 owner team 有 belief 才納避讓,★全圖 loop 保留 belief filter 加 loop 內,store-free)。TDD 2型。gate PASS(jhost gv_teamstate 修後 removed=1/enemy_outpost gv_mapscan loop 保留仍在=PASS,★別碰 baseline.txt——merge 時 systems 改)。headless 0new/determinism 2跑 byte-identical(無新RNG)/★measure=enemy_outpost behavior-sensitive(選址分佈/衝突率/doom-delta seed1337/42;jhost 輕)。off LOCAL main a4a04afb。task=systems+reviewer。做完→to:measurer。"
---

# dispatch：god-view follow-up（enemy_outpost + jhost belief-gate，R² CLEAN）

detector v3（f7ff2ea0）機器證揪出 arc A/F/E/D/B/C **人審漏**的 2 真殘留 god-view leak。reviewer R² 判**兩者真 leak + fix CLEAN**。spec：`docs/superpowers/specs/2026-07-20-godview-followup-enemy-outpost-jhost.md`。

## ★★ branch base
- **off LOCAL main `a4a04afb`**（post-1119 已 merged，避 faction_ai 衝突）。pre-push hook 已裝。

## 修 2 site

### ① jhost（`decision_context.gd::gather:373`）trivial=同 1119 belief_pos
現況：`var _reachable = not PathSystem.find_path(state, team.tile_pos, state.teams[_jhost].tile_pos).path.is_empty()`
修：
```gdscript
var _jpos: Vector2i = BeliefSystem.belief_pos(state, team.team_id, _jhost)
var _reachable: bool = _jpos != Vector2i(-1, -1) \
    and not PathSystem.find_path(state, team.tile_pos, _jpos).path.is_empty()
```
無 belief（positionless/斷視線太舊）→ `_jpos==(-1,-1)` → 不可達（不知對方在哪=無法算 join 可達）。`team.tile_pos`=自身不動。

### ② enemy_outpost（`faction_ai_system.gd::_enemy_outpost_positions:2912`）belief-about-owner proxy
用途=`_evaluate_new_outpost_location:2851-2855` 選址軟 penalty（建近敵據點<5 減分）。全圖掃回**全部**敵據點=瞬知全敵基建。
修（★**全圖 loop 保留**，belief filter 加在 loop **內**，store-free 復用既有 belief）：
```gdscript
    if owner.faction_id == leader_team.faction_id and owner.faction_id != -1: continue
    # ★belief-gate（owner-belief proxy）：只避「觀察者對 owner 隊有 belief(見過/聞得)」的敵據點
    #   非全知。imperfect(belief 給 owner last-seen 位非據點位)但軟 penalty 容忍+store-free。誠實標籤。
    if BeliefSystem.belief_pos(state, leader_team.team_id, owner.team_id) == Vector2i(-1, -1): continue
    out.append(tile.tile_pos)
```
語意：知道對方存在（見過該敵隊）才避其據點；未知敵不避→有時建 near 未見敵→更多衝突湧現（合鐵律）。

## 驗收
- **TDD 2 型**：①jhost 可見→belief 位算可達/斷視線 recent→last-seen/positionless→(-1,-1)→不可達。②enemy_outpost：owner 有 belief→納入避讓/owner 無 belief→不納。
- **gate** PASS：jhost gv_teamstate 修後 fingerprint drop → **removed=1**（PASS）；enemy_outpost gv_mapscan **loop 保留仍命中**→ current 有=PASS。★**別碰 `constitution_baseline_v2.txt`**——merge 時 systems 改（jhost 移除 + enemy_outpost re-label gate-ok）。
- **headless** 0 new（現 baseline：2 [FAIL] Team23建設/弱目標 + 3 assertion=join weight/combat197/rung擴張，皆 pre-existing）。**determinism** 2 跑 byte-identical（無新 RNG）。
- **★measure（→measurer，enemy_outpost behavior-sensitive）**：選址分佈/衝突率/doom-delta（seed1337/42）；jhost 輕。doom-delta 惡化不明顯即 OK（更多衝突 arguably 更好戲，blueprint 看數字）。

## ★god-view arc 收尾
2 site merged + systems baseline 訂正 → **真 zero-untracked-god-view-residual** → 報 blueprint arc 收官 → economy arc（re-baseline，補丁閘優先查）。

## 完成判定 = systems + reviewer。做完 → to:measurer。
