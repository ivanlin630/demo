# care-loop scout de-patch HOW（ii relief-cluster 第一刀、補丁閘 execution-break）

**status**: LOCKED（R² CLEAN 2026-08-08、reviewer 親驗 premise+感知鐵律 5 邊界+保序+零 crank；1 輕量必查項=§修/§1 措辭訂正「roster 純加第三層 final fallback、非取代 last_known_pos」已訂正）
**scope**: ii relief-decision cluster 第一刀 = care-loop scout 執行斷點 de-patch（blueprint 裁 ii、care-loop 先、補丁閘優先查）。
**premise**: measured + file:line 坐實（R① 免、非未驗斷言）——measurer care-loop tap：care argmax 真贏 30+ 次（義氣0.6 lord genuine）、`care.scout_dispatched=0` 全 45 天；根因 `_dispatch_care_scout:5114` `vpos==(-1,-1)` silent-return（Team2 從沒形成 belief）= circular（要 scout 學狀態需位置、位置只 belief 有、無 belief→不能 scout→死鎖）。
**連**：[[feedback_patch_gate_first]]（built 不 fire 先查 gate）、[[feedback_verify_execution_end]]、[[project_information_network]] 結構常識補則、[[project_size_matter_arc]] scale 底查 relief-death cluster。

---

## 病（execution-break、circular）
`_dispatch_care_scout`（faction_ai:5110-5123）：領主 care-loop 決定查自家村 → 需目標村位 `vpos`：
```
var vpos = BeliefSystem.best_estimate(state, team.team_id, vid).get("tile_pos", entry.get("last_known_pos", Vector2i(-1,-1)))
if vpos == Vector2i(-1, -1):
    return   # 無 belief/last-known → 查不了 ← ★silent-return 死鎖
```
領主對 7-8hex 外自家村 Team2 **從沒形成 belief**（超 belief 觸及）→ vpos=(-1,-1)→ silent-return → 30+ 次 care 決定全**零 dispatch**。**circular**：scout 目的=學村狀態，卻要求先有村位 belief；領主對未接觸村無 belief → 永遠查不了。

## 修（de-patch：belief 缺 → fallback 組織常識 roster 位）
領主**結構知自家 faction 固定據點位置**（LOCKED info-net core spec §結構常識補則「faction 成員天生知自家所有固定據點位置=組織常識、position-only、新據點公告傳播」）。∴ care scout 目標位在 belief + ledger 快照**皆缺**時，應**再加一層** fallback `_faction_roster_pos`（faction_ai:4664 static、已 gate-ok 組織常識 accessor）——**純加最終 fallback、不動既有 belief/ledger 兩層**：
```
# 現況兩層（belief.tile_pos → entry.last_known_pos 快照）不動、僅在其後補 roster 第三層：
var vpos = BeliefSystem.best_estimate(state, team.team_id, vid).get("tile_pos", entry.get("last_known_pos", Vector2i(-1,-1)))
if vpos == Vector2i(-1, -1):
    vpos = _faction_roster_pos(state, team, vid)   # ★組織常識 final fallback：belief+ledger 快照皆缺→領主仍知自家村位（position-only）
if vpos == Vector2i(-1, -1):
    return   # 仍無（非自家 faction / factionless target）→ 查不了（保）
```

## ★★§HOW-binding（寫死必守）
1. **既有兩層零覆蓋、roster 純加第三層 final fallback**（R² 訂正措辭）：現況 `belief.tile_pos → entry.last_known_pos`（_ledger_record 存的 belief 快照）兩層**不動**；roster 僅在**兩層皆 (-1,-1)**（Team2 案：從沒 belief→快照亦 (-1,-1)）時作**最終 fallback** 補洞。★不是取代 `entry.last_known_pos`——是其後再加一層（roster 讀當下 outpost 位=同語意「村在哪」、比舊快照更新鮮、遷村後更準；但語意層次上 roster 排最後=belief/ledger 有值優先）。
2. ★**感知鐵律守**：`_faction_roster_pos` = **position-only 組織常識**（領主知村在哪=靜態 outpost 位、已有 gate-ok 標記）——**非 god-view live-state**。scout **仍物理走 dispatch_anon_messenger + 觀察 state + 延遲**（founding_timeout(dist)）→ 領主**不**因 roster 就知村餓/狀態（那要 scout 抵達親見）。roster 只解「村在哪」（LOCKED spec-sanctioned）、非「村怎樣」。
3. **own-faction only**：`_faction_roster_pos` factionless target 回 (-1,-1) → 仍 silent-return（不對非自家 target 亂 scout）= 正確保留。
4. **throttle 保**：`pop<2 / _has_inflight_info` early-return 不動（真成本、一隊一 scout）。
5. **零死常數 / 零 crank**：純 de-patch（移 belief-only 硬前提）、care/ignore util 不動（genuine 已驗）、無新常數。

## 驗收
- ★**care.scout_dispatched > 0**（領主真派 scout 查 Team2、破 silent-return）。
- ★**death-spiral 破否（核心）**：scout 抵達→親見 Team2 餓→領主 relief/distribute fire→**Team2 defect(day25) 前得救**→dispersed attrition 降（seed8181 dispersed 45天：Team2 存活否 / relief_dispatched true / defect 消否）。
- ★**care-loop 單修是否足**（measure-first、避過 fix）：若 death-spiral 破 → 2a 求援-ordering + A propagation = **follow-up 待需再 spec**（不過 fix）；若不足（scout 到了但 relief 沒接上 / 仍 defect）→ 揭下一站斷點 → 續 ii。
- 感知鐵律：constitution_gate 綠（roster fallback = 既有 gate-ok 組織常識 accessor、無新 indexed 他隊 live 態讀 / 無 whole-map god-view）。
- determinism 3-run byte-identical（roster=靜態讀、零 RNG）；headless 0-new。
- ★行為變 slice：fp 對 baseline **預期分化**（領主開始 scout=intended、非 byte-identical）；記錄 intended。

## 序
spec 自檢 → **R²**（結構審：de-patch 邊界 + 感知鐵律 roster=position-only 非 god-view + belief-優先-roster-fallback 保序 + own-faction-only + throttle 保）→ build（care-loop scout 真 fire 驗）→ 量（death-spiral 破否 + care-loop 單修足否）→ QA（specimen 故事：scout→親見→relief→Team2 defect 前得救）→ merge → re-measure scale（乾淨 base）。★R① 免（premise measured+file:line 坐實非未驗斷言）。
- ★staged：care-loop 第一刀；2a 求援-ordering（genuine 峰值絕境 求援先於 defect、非 crank）+ A propagation complementary = 待 care-loop 量測後定需不需（blueprint ii 全景、避過 fix）。iii factionless-death-spiral 深根=flag（cohesion territory、用戶 WHAT 裁、本批不動）。
