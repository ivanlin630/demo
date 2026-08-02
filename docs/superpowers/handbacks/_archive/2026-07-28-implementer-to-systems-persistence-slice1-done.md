---
from: implementer
to: systems
status: consumed
topic: "[done·持守統一 Slice 1 決策層 bonus-collapse·請 R²(Slice1)] feat/persistence-slice1-bonus-collapse 6912c6a7 off local main 7fa04f38。新 team.persist_strength 欄+PersistStrength 公式 helper(人格加權沉沒成本,progressive-only,clamp 0.3<危機)+3 live flat commitment bonus 改讀(COMMANDER/FOUND/COMMITMENT×2)。★scope 註:SOLO_COMMITMENT_BONUS=dead 未用(skip);survival_committed_stall=stall 偵測結構異(已 stall_patience_factor 人格化,非 flat util bonus)→請 R² 裁納 Slice 幾。驗:formula 5/5+headless 0-new+gate 74+determinism byte-identical(052c0924)+★世界不凍(teams 49→64 成長/pop flux/attrition 1.13% vs baseline 1.80%=兩者皆活,latch 反例)。人格分化(固執 0.3/務實 0.06)。不碰執行層(Slice3)。"
branch: feat/persistence-slice1-bonus-collapse
commit: 6912c6a7
base: 7fa04f38 (local main HEAD)
spec: docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md §4/§5/§8-Slice1/§9
---

# done：持守統一 Slice 1（決策層 bonus-collapse）——請 R²(Slice 1)

## 做（spec §4/§5/§8 Slice 1）
1. **新 `team.persist_strength` 欄**（TeamData，float default 0；Slice 2 執行層讀）。
2. **`PersistStrength` 公式 helper**（`scripts/simulation/decision/persist_strength.gd`）：
   - `persist = clampf(PERSIST_CAP × progress × commitment_lean, 0, PERSIST_CAP)`，PERSIST_CAP=0.3。
   - **progress** = committed 時間佔比（Slice 1 決策層自算 proxy；Slice 2 補真 construction-tick + 進度事件新鮮度）。
   - **commitment_lean** = `0.5 + (stick − flex)`：stick=(慎重+義氣)/2 死硬完成→lean→1.0；flex=(貪婪+野心)/2 靈活轉換→lean→0.2。（spec 的 固執/機會 不存在→映既有 values。）
   - **progressive-only gate**：FLEE/IDLE → 0（開放式/無承諾不套持守，走既有 timeout）。
   - **憲法（§9）**：weigh 非 gate（連續權重非硬類別）；非 latch（util 偏置 max 0.3 < survival boost 2.5=危機永可打斷→**不凍世界**，≠ latch skip-reeval）。
3. **3 live flat commitment bonus 改讀 persist_strength**（bonus-collapse）：
   - `COMMANDER_COMMITMENT_BONUS`（戰略意圖 hysteresis，`select_strategic_intent`→`_argmax_intent` 加 persist_bonus 參數）。
   - `FOUND_COMMITMENT_BONUS`（建國 hysteresis，`_evaluate_independent_strategy`）。
   - `COMMITMENT_BONUS`（`decision_engine.rank_scored_ctx:88` current_option + `rank_survival:176` previous_task）。

## ★scope 註（請 R² 裁）
- **`SOLO_COMMITMENT_BONUS`（:87）= dead code**（grep 全 repo 無用點，只定義）→ 沒得 collapse（skip；可另刀刪常數）。
- **`survival_committed_stall`（faction_ai:3660）= 結構異**：非 flat util bonus，是 committed survival option **stall 偵測**（`stall_verdict` + `stall_patience_factor` 已用 慎重/求生欲 人格化），且屬 §2 排除的 crisis/survival axis。**未改**（改它=動 survival stall 偵測，風險高+違 §2 crisis 排除）。→ 請 R² 裁：留原樣 / Slice 2+ / 明確排除。
- ∴ 實際 collapse = 3 live flat commitment bonus（COMMANDER/FOUND/COMMITMENT）。

## 驗（全綠）
- `persist_strength_test` **5/5**：progressive-only gate（FLEE/IDLE→0）/ sunk-cost progress（committed 越久越黏，剛 committed≈0 易轉無鎖）/ ★人格分化（固執 0.300 vs 務實 0.060）/ clamp ≤PERSIST_CAP<SURVIVAL_BOOST_MAX / compute 寫欄。
- headless **0-new**（6 baseline；strategic-intent 測 923-945 未破=COMMANDER 改讀不退化）。
- `constitution_gate` **74 removed=0**（persist 是 rank 偏置非 god-view/RNG/新閘）。
- determinism **3跑 byte-identical** `052c0924`（純算術零 RNG）。
- **★★世界不凍（latch 反例回歸，specimen-off）**：seed1337 1mo persist vs baseline(main)：

| | baseline(main) | persist Slice 1 |
|---|---|---|
| start→end pop | 444→436 | 444→439 |
| attrition | 1.80% | 1.13% |
| final teams | 71 | 64 |

→ **兩者皆活**（pop flux + teams 49→64 成長，非 latch-freeze 的逐月 FLAT）。persist 略靜（bonus-collapse fresh-commit 少偏置=行為位移，非凍）——whole-system measure（Slice 全建完）判平衡。

## 待
systems R²(Slice 1)——尤其：persist 公式對否（time-proxy Slice 1 vs 真 construction-progress Slice 2）+ survival_stall scope 裁 + 世界不凍認可 → merge → Slice 2（執行層寫回 + 進度事件新鮮度）。execution-verified（人格黏著真發生 + 世界不凍）已附。material PARK。
