---
from: implementer
to: systems, qa
status: open
topic: A2b — faction leader 隊納統一引擎（3 task 完成）
---

# Hand Back: A2b — faction leader 隊納統一引擎

**Branch:** `feat/A2b-impl`（基於 `origin/feat/A2b`=3235228，已 push）
**Plan:** `docs/superpowers/plans/2026-07-08-A2b-leader-into-engine.md`（全 3 Task 完成）

## 實作摘要

| commit | 檔案 | 說明 |
|---|---|---|
| c86dfad `feat` | `scripts/data/faction_data.gd` | +`intent_eval_next_tick:int` 欄（cadence 追蹤，鏡射 team threat/subteam_eval_next_tick） |
| c86dfad `feat` | `scripts/simulation/faction_ai_system.gd` | +`INTENT_CADENCE`=1 日 const；`_update_goals` 步驟2 intent 選擇 cadence-gate（`current_tick>=intent_eval_next_tick` 才 `_select_intent`，否則沿用 `f.intent`；empty fallback=守成） |
| 6b43ef9 `refactor` | `scripts/simulation/faction_ai_system.gd` | `_assign_tasks` 拆 徵收/外交/攻擊/掠奪 手 cascade + `note_bypass`→`_decide_unified(leader_team)`；立國 lifecycle-gate 上移至 player_cmd 之後、engine 之前（pre-empt）；保 header/survival-sticky/player_cmd(PRIO_PLAYER) |
| 074f73b `chore` | `scripts/debug/constitution_baseline.txt` | `_assign_tasks` 註記更新（leader tactical→engine；fingerprint 保留=player_cmd try_set 仍在） |

**與 spec/plan 差異：** 無。純路由，零 target 變、零 term patch、零 ctx 改。plan 每 step 照做。

## 驗收證據（seed 1337，1 月＝7200 tick）

**手聽腦 bed（`hand_obeys_brain_bed.gd`）：**
| 指標 | 改前(baseline) | Task2 後 |
|---|---|---|
| **leader_bypass** | **11** | **0** ✓（TDD 目標達成） |
| 引擎 dispatch 決策點 | 13159 (unified=13115) | 15820 (unified=15765) ← leader 戰術現全經引擎 |
| obey（手==腦） | 98.6% | 92.7% |
| unified 背離率 | 0.5% (viol=66) | 4.5% (viol=706) |
| determinism 同 seed 兩跑 | PASS | **PASS**（run1=run2 逐事件 dec=15820 viol=706 ev=706） |
| 非擾動 vs WarringHarness | MATCH | MATCH（teams=55 factions=8 pop=372） |

- Task1（cadence）獨立驗：determinism PASS、決策點/leader_bypass 皆同 baseline（cadence 行為中性）、`game_sim_multi` IntentThrash=0.0%（意圖穩定）。
- Task3 憲法閘：`[CONSTITUTION-GATE] PASS (sites=30, removed=0)`（`_assign_tasks` fingerprint 保留＝player_cmd try_set 仍在，非新增違憲落點）。

**sanity（`game_sim_multi.gd`，21600 tick）：** 無崩、CoinAudit delta=0.00、InvariantSummary 違反=0。徵收流通（多筆 `[Tribute]`／`[SubAI] 引擎→徵收`）、外交發生（`引擎→外交(求和)`／propose_alliance）、combat 發生（敗×32/戰鬥×4）。

## ⚠ 待 QA 判決（implementer 不判，plan 明列 QA 階段硬項）

1. **obey 98.6%→92.7% / viol 66→706 的解讀**：非我引入的 regression。leader ~2661 個戰術決策從「bypass（不計 obey/viol）」移入「unified（現對照引擎 winner 量測）」，surface 出 leader 本就存在的 `arbiter_latch`/`subset_fallthrough`（成員早已同型）。=可見性上升非行為退化。**請 QA 確認此解讀**，或若 leader 背離型態需另修再回報。
2. **★守衛 A（00 硬閘）**：長跑 seeded（≥數千 tick）leader **征服稀有非零**。sanity 只前哨（見 combat 發生但未隔離「自發 engine leader 攻擊」，因舊 `[FactionAI] 主動攻擊` print 隨 cascade 拆除已移除）。**需 QA 長跑硬驗 count>0**。
3. **★守衛 B（00 硬閘）**：遠距 member 仍有貢賦流入（拆掉的 tribute-detachment subteam 分支＝00 sign-off 移除項；現遠距徵收改走引擎 try_set 就地 or 引擎自身 dispatch）。**需 QA 驗 TRIBUTE 成交/treasury 增>0**。
4. target 保真、prio 降 regression、效能（≤5%）、抖動檢 — 見 plan QA 段。

## 連動風險

- `_richest_member`/`_nearest_independent`/`DISPATCH_DIST_THRESHOLD`/`SubteamSystem` tribute-detachment：`_assign_tasks` 已不用，但 grep 確認他處仍用（`options.gd`/`decision_context.gd`/`_conquest_viable`）→**未刪 helper/const**。無死碼新增。
- 遠距徵收派子隊（tribute-detachment）行為移除＝00 sign-off un-patch。若守衛 B FAIL，代表引擎 tribute option 未覆蓋遠距情境，需系統補（非回退補丁）。
- 成員/solo/子隊/conquest scaffolding 路徑未碰。

## 待主 session 確認
- 建議 QA 跑守衛 A/B 長跑 seeded + 效能 before/after。
- 無 spec 未覆蓋的設計決策；無新增建議 task。
