# Plan — G3 Phase E：enforce（belief 真正驅動決策）

> 實作 plan。spec = `specs/2026-06-29-g3-info-warfare-unified-design.md` §4 Phase E。
> 信息域不變量：**凡決策用的 belief 必追得回 provenance；決策直讀 god-view 真值 = 違規**（比照決策域「無因令=0」硬 assert）。
> **本 phase = enforce（欺敵有後果的前提）。不含 Phase D 植假/Phase P 玩家呈現。**

## 前置（開頭必跑）
```bash
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # 基準 PASS 數
```
既有 belief API（`belief_system.gd`）：`best_estimate(state,obs,tgt)→Dict{population_est,food_est?}`（:87）、`uncertainty`（:102）、`confident_enough(state,obs,tgt,caution)`（:121）、`record_claim`（:126）。已轉 belief 的乾淨面：`_find_weakest_prey`（faction_ai:2715）、diplomatic 評分（:21-24）— **複用同 pattern，別重造**。

## Task 1 — god-view leak 補（5 處，逐處 best_estimate）
每處 TDD：先造「真值≠belief」測（植低 population_est 假 claim / 或無 claim fallback），斷言決策走 belief 非真值。用既有 `best_estimate`（無 claim → `{}` → 定 fallback：無情報時保守/不行動，**非**偷讀真值）。

- **1a `diplomatic_ai_system.gd:65`**（demand_tribute power_gap）：`other.population` → `best_estimate(state, self_id, other_id).population_est`（無估 → skip 或最保守）。與 :70 `confident_enough` gate 一致（現只 gate 行動、power_gap 仍真 → 補齊）。
- **1b `faction_ai_system.gd:2750-2752`**（`_find_strong_neighbor` join 決策）：`t.population` → belief est（無估 → 該 neighbor 不列 candidate，不憑真值選）。
- **1c `faction_ai_system.gd:2762-2763`**（`_find_aid_target` 讀 pop+food）：`t.population`/`t.resources.food` → belief est（`population_est` + `food_est`；無 food_est → 保守 skip）。
- **1d `diplomatic_ai_system.gd:131`**（demand_tribute 回應 accept/refuse 讀 sender 真 pop）：`sender_team.population` → belief est（收訊者對 sender 的估；無估 → 按身份信任保守）。
- **1e `diplomatic_ai_system.gd:180-185`**（`consider_betrayal` fallback `ally_team.population` 真值）：已優先 `known_member_states` snapshot；fallback 真值改 belief est（無 snapshot 且無 belief → 最保守=不背叛）。**與 Task 3 合流**。
- **不碰**（同 faction 內部協調、非敵情，讀真值合法）：merge/consolidate（:1060/1072/1145）、faction/global tally（:1630/1650/1991）。**plan 註明刻意豁免**（同勢力共享情報 believable）。
- **DoD**：5 處走 belief、各處「真值≠belief」測綠（AI 按 belief 錯判可發生 = 自信地錯地基）；同 faction 內部讀不動。

## Task 2 — provenance 審計閘（不變量 enforce）
「凡決策用 belief 追得回 provenance」的**回歸測化**（自動 assert，比照 InvariantAudit）：
- **測**（`headless_test.gd` `_test_belief_drives_decision`）：seed 一局，對 X 植**假**低 population_est claim（真值強、belief 弱），confident_enough 過 → 斷言掠食/tribute/join 決策**按 belief（弱）行動**（打真值強的 X）→ 證決策無偷讀真值。反向：植假高 → 斷言避戰。
- **invariants.md**：補一條「信息域：凡決策讀 belief（`best_estimate`）非 god-view 真值；例外=同 faction 內部協調（共享情報）」。列已豁免點。
- **（可選）audit probe**：`InvariantAudit` 加「decision-belief」掃描——靜態或 runtime 標記 AI 決策路徑讀 other-team 真 stat（若成本高則降為 code-review checklist + 上述測，plan 執行時裁）。
- **DoD**：假 belief → 決策跟 belief 的測綠；invariants.md 補條 + 豁免清單；審計手段落地（測 or probe）。

## Task 3 — 背叛 belief 驅動化（去純 RNG）
- 現況 `diplomatic_ai_system.gd:188`：`if betrayal_score > 0.65 and randf() < 0.1`（`betrayal_score`=人格 野心/信義/義氣 blend − 0.3 if power_gap>0.5）。
- **改**：`power_gap` 用 belief est（Task 1e）；`betrayal_score` 折入 belief 驅動項「Y 弱/我有利」= belief est 的 power advantage（我 est 強於盟 → 背叛動機↑）。**驅動可解釋**（背叛 = belief「盟弱我利」+ 人格，非骰子）。
- **RNG**：`randf() < 0.1` 純機率 → 改 belief-confidence 調變（低 uncertainty + 高 advantage → 觸發率↑；保留小 stochastic tie-break，非主驅）。TEST VALUE。
- **測**（`_test_betrayal_belief_driven`）：植假「盟弱」belief → 背叛動機↑可觸發；植「盟強」→ 不背叛。斷言背叛帶可解釋 driver（belief advantage + 人格），非純 roll。
- **DoD**：背叛讀 belief power_gap、driver 可解釋、測綠；戰國 seed 背叛率不崩（不暴增/歸零）。

## Task 4 — 活世界回歸（戰國 seed）
- `warring_states_seed`（`GODOT_TIMEOUT=2500` + bg）：
  - **自信地錯發生**：高感知 cred + 真值≠belief → AI 按錯 belief 行動（被咬）可量到。
  - 背叛按 belief 驅動、率合理（非崩）。
  - god-view 決策=0（審計閘）。
- **DoD**：自信地錯量到、背叛率合理、審計 0；誠實標活世界 emergence 到不到。

## Task 5 — 守恆 + 回歸閘
```bash
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # PASS ≥ 基準
# coin_eq delta=0 / pop 守恆 / InvariantAudit 0 / 1000+ tick 無錯
```
- **DoD**：framework S1-S6 PASS、coin_eq=0、pop 守恆、無 GDScript 錯。

## 不碰（scope guard）
- Phase D（植假 primitive/離間/假和）、Phase P（玩家呈現）、Phase 擴充（channel verbs/信用幣）— **本 phase OUT**。
- 同 faction 內部真值讀（協調，刻意豁免）。
- belief 基質重造（複用既有 `belief_system.gd`）。

## 完成
- handback → 系統：5 leak 補完、審計閘手段（測/probe 哪個）、背叛 belief 化結果、自信地錯活世界證。**誠實標** enforce 到不到（決策真跟 belief 走）。銜接 Phase D（植假）需求。
