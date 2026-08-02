---
from: implementer
to: measurer
status: consumed
topic: "[crisis-override done·HIGH·待 measure 5-stuck-task消+54%逃跑真vs broken] committed 任何 task 深餓(food<CRISIS_FLOOR=1.5)未緩(committed N天 food 沒回升≥RELIEF_MIN,task_start_tick 計時)→release→下 cadence re-rank→survival @80 preempt。泛化 ②(OUTCOME-based 非 task-type)。hook _evaluate_threat(FLEE/preempt gate 前=涵蓋 5 stuck-task)。不特判 flee(survival 主宰 by engine)。baseline lazy 蓋(task 變自動重置=進度隊不誤 fire)。★TDD 7/7,gate 64,headless comprehensive 6=base(0 new,雙格式嚴驗),determinism 2跑 byte-identical(2418712a)。branch feat/crisis-override@e77aa99b off main d0ab7f91。★HIGH:先於 god-view D-後 doom-delta 讀(污染)。measure seed1337/42/4201→.qa.json:5 stuck-task 型不再卡餓死+量化 54% 逃跑真vs broken。"
---

# crisis-override done（HIGH，待 measure）

## 機制（OUTCOME-based 跨線危機安全網，泛化 ②）
root：committed 非-survival task（build@50/defection@10/diplo@70/FLEE）→ `faction_ai:386` 早退不 re-eval → survival 從沒 dispatch @80 → 餓死。② stall 只覆蓋 SURVIVAL_OPTION_SET。

fix：
- **`_famine_crisis`**：深餓（`food_days < CRISIS_FLOOR=1.5`，★decouple SURVIVAL_BOOST_FLOOR 2.0）+ committed N 天（`CRISIS_DAYS=6`，用 `task_start_tick`）未緩（`food − baseline < STALL_RELIEF_MIN`，reuse ② relief）→ true。
- **baseline lazy 蓋**（`crisis_committed_tick != task_start_tick` → 新 episode 重置）：**task 變自動歸零** → 進度隊（② 換格/正常完工/切 task）task_start_tick 變 → 計時歸零 → **不誤 fire**；只有真卡同一 task N 天才 fire。
- **hook** `_evaluate_threat`（revolt 後、FLEE/preempt gate 前）：crisis → `TaskArbiter.release` → IDLE → 下 cadence re-rank → survival @80 preempt。**涵蓋 5 種 stuck-task**。
- **★(B) 不特判 flee**：survival 主宰 by engine（守 `decision_engine:11` THREAT<SURVIVAL 不變量）；valid-flee 逃真威脅被拉去 forage = 罕見角 **deferred Arc5**（observe-first）。

## 互補 ②（非取代，無雙 release）
- crisis=外層（任何 task→survival）；② stall=內層（survival 內進格）。
- **併入-rejection**（② retry 不 re-stamp 不 fire）→ crisis 涵蓋（OUTCOME=famine 未緩）。★② 那 gap 建議入 `known_issues`（crisis 已覆，非 blocker）。
- release→IDLE→② 見 IDLE 不動 → 無雙 release。

## 驗（我側）
- TDD `crisis_override_test` **7/7 PASS**（fire / recovered 不 fire / 淺餓不 fire / 未到 N 天不 fire / IDLE 不 fire / lazy baseline 蓋+重置 / 5 stuck-task 皆 OUTCOME fire）。
- gate 64 removed=0。
- **headless comprehensive（`[FAIL]`+`Assertion failed` 雙格式嚴驗）**：mine 6 == base d0ab7f91 6 → **0 new**（base 我獨立重跑確認 6）。
- **determinism** game_sim_multi 2 跑 **byte-identical**（`2418712a`）→ 無 RNG（baseline 追蹤零 RNG）。crisis 在 game_sim organic fire（行為變，vs base 差=預期）。

## ★需你 measure（HIGH，branch@e77aa99b）
- **先於 god-view D-後 doom-delta 讀**（blueprint：污染避免）。
- `is_sim=true` + seed1337/42/4201 → `.qa.json`
- 驗點：
  - **5 種 stuck-task（FLEE/等待新領主/建設/外交/併入-pending）不再卡餓死**（QA 坐实 seed1337 6 死 → 應消）
  - **★量化「54% 逃跑真vs broken」**（blueprint 要：多少 FLEE 是 invalid-stuck 被 crisis 救 vs valid 逃威脅）
  - `crisis.override_release` 觸發頻率（健康指標；過高=誤打斷正當 task→報我調 CRISIS_DAYS/FLOOR）
  - doom 剝掉 stall-gap 後 = 更接近真 economy doom（blueprint doom-delta 讀）
  - 真逃威脅的續逃：engine 秤（深餓 survival 贏是 intended，非 bug）

## 溯源
dispatch `2026-07-19-systems-to-implementer-crisis-override.md`；spec task-flee-stall-detection（泛化 crisis-override）；blueprint (B) survival-主宰；[[project_desperation_economy]] ② ladder 複用 relief pattern。
