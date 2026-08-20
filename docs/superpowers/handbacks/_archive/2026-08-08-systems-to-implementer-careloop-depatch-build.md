---
from: systems
to: implementer
status: consumed
topic: "[dispatch build care-loop scout de-patch(ii relief-cluster 第一刀、補丁閘 execution-break、行為變 slice、spec docs/superpowers/specs/2026-08-08-careloop-scout-depatch-HOW.md LOCKED R² CLEAN)·新 slice feat/careloop-scout-depatch off 更新後 main(1a29352c、含框架 F1-F4+scale 底查 docs)·★修=_dispatch_care_scout(faction_ai:5110-5123)vpos 三層 fallback:現況兩層(belief.tile_pos→entry.last_known_pos 快照)不動、僅其後補第三層 roster——vpos==(-1,-1)時 vpos=_faction_roster_pos(state,team,vid)、仍 (-1,-1)才 return·★★§HOW-binding 寫死:①既有兩層零覆蓋、roster 純加第三層 final fallback(非取代 last_known_pos、reviewer 訂正措辭)②感知鐵律=roster position-only 組織常識(領主知村在哪靜態 outpost 位)非 god-view;scout 仍 dispatch_anon_messenger 物理走+founding_timeout 延遲+抵達親見 state(領主不因 roster 知村餓)③own-faction only(_faction_roster_pos factionless→-1 仍 silent-return 保)④throttle(pop<2/_has_inflight_info)不動⑤零 crank/死常數(care/ignore util _pick_care_reaction 零改 genuine)·★★驗收:①care.scout_dispatched>0(領主真派 scout 查 Team2 破 silent-return)②★death-spiral 破否核心(scout 抵→親見餓→relief/distribute fire→Team2 defect day25 前得救→dispersed attrition 降;seed8181 dispersed 45天 Team2 存活否/relief_dispatched true/defect 消否)③constitution god-view detector 綠(roster 既有 gate-ok accessor 無新 live 態)④★行為變 slice=fp 對 baseline 預期分化(領主開始 scout intended 非 byte-identical、記錄)+determinism 3-run byte-identical(roster 靜態零 RNG)+headless 0-new·★staged:care-loop 第一刀、量 death-spiral 破否再定 2a 求援-ordering/A propagation follow-up 需不需(避過 fix、勿本 slice 做)·完成 handback to:systems R²(merge-gate 核三層保序+感知鐵律 roster 非 god-view+scout 真 fire+fp 分化 intended)→量測員量 death-spiral→QA specimen(scout→親見→relief→defect 前得救)→merge→re-measure scale·地基 KEEP"
---

# dispatch build care-loop scout de-patch（ii relief-cluster 第一刀、補丁閘 execution-break、行為變）

spec：`docs/superpowers/specs/2026-08-08-careloop-scout-depatch-HOW.md`（LOCKED、R² CLEAN）。新 slice `feat/careloop-scout-depatch` off 更新後 main（`1a29352c`）。

## ★修
`_dispatch_care_scout`（faction_ai:5110-5123）vpos **三層 fallback**：現況兩層（`belief.tile_pos → entry.last_known_pos` 快照）**不動**、僅其後**補第三層 roster**——`vpos==(-1,-1)` 時 `vpos = _faction_roster_pos(state, team, vid)`；仍 `(-1,-1)` 才 return。

## ★★§HOW-binding（寫死必守）
1. **既有兩層零覆蓋、roster 純加第三層 final fallback**（非取代 last_known_pos、reviewer 訂正措辭）。
2. **感知鐵律**：roster = position-only 組織常識（領主知村在哪=靜態 outpost 位）非 god-view；scout 仍 `dispatch_anon_messenger` 物理走 + `founding_timeout` 延遲 + 抵達親見 state（領主不因 roster 知村餓）。
3. **own-faction only**（`_faction_roster_pos` factionless→-1 仍 silent-return 保）。
4. **throttle**（pop<2 / `_has_inflight_info`）不動。
5. **零 crank/死常數**（care/ignore util `_pick_care_reaction` 零改 genuine）。

## ★★驗收
1. `care.scout_dispatched > 0`（領主真派 scout 查 Team2、破 silent-return）。
2. ★**death-spiral 破否（核心）**：scout 抵→親見餓→relief/distribute fire→Team2 defect(day25) 前得救→dispersed attrition 降（seed8181 dispersed 45天：Team2 存活否 / relief_dispatched true / defect 消否）。
3. constitution god-view detector 綠（roster 既有 gate-ok accessor、無新 live 態）。
4. ★**行為變 slice=fp 對 baseline 預期分化**（領主開始 scout=intended 非 byte-identical、記錄）+ determinism 3-run byte-identical（roster 靜態零 RNG）+ headless 0-new。

## 序
★staged：care-loop 第一刀、量 death-spiral 破否再定 2a 求援-ordering / A propagation follow-up 需不需（避過 fix、**勿本 slice 做**）。完成 → handback `to:systems`（R² merge-gate 核三層保序 + 感知鐵律 roster 非 god-view + scout 真 fire + fp 分化 intended）→ 量測員量 death-spiral → QA specimen（scout→親見→relief→defect 前得救）→ merge → re-measure scale。地基 KEEP。
