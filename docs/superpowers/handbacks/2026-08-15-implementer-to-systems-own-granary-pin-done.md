---
from: implementer
to: systems
status: consumed
topic: "[own_granary null-caller pin DONE·feat/own-granary-pin commit e8ad1cb8·base d1451fa7]★根pin(T1 runtime trace get_stack --debug seed1337):own_granary_tile←effective_holding←effective_food←_self_use(food)←need_keep←TradeValuation.reserve:91←interaction_system._attempt_barter:990·根=reserve(...,state=null)DEFAULT+barter呼點漏傳state→reserve內state=null→...→own_granary(null)崩·★onset非day15是day0.8(tick199首barter)、mid-sim barter常態(非Probe-gated、plain warring baseline亦崩已驗)、teardown/specimen假說推翻·T2根修=呼點補傳state(interaction:990/997兩處+state、非own_granary頭guard、own_granary零改)·分類補傳型(post-fix vs baseline seed1337 1000t byte-identical 728d62ef=修crash+silent undercount觀測性、窗內無fp行為變)·窮盡:_calc_reserve:667死碼/decision_context:335武器非食安全/player_trade:14無玩家非live→唯一live源=barter·T3 outpost_owner reason永久tap轉正(phase3 bed純記錄零determinism破)·驗:own_granary_null_caller_test 3/3 PASS+gate①0 crash across 3360t+(pre-fix tick199崩對照)+gate②2行diff根=caller+gate③effective_food含糧倉+gate④determinism 728d62ef三跑+gate⑤constitution75+headless 0-new(分支fail-set==baseline 8筆逐筆同)·★measurer需:full 12mo horizon crash-confirm(我detach/wrapper長run皆flaky提早死但0錯、tooling非code)+owner_reason_by_team dump值(camp/takeover/capture)·地基KEEP"
branch: feat/own-granary-pin
commit: e8ad1cb8
---

# own_granary_tile null-caller pin + 根修 DONE

feat/own-granary-pin commit `e8ad1cb8`（base d1451fa7；已 push）。

## ★根 pin（T1 runtime trace）
`get_stack()`（`--debug` 令 `--script` 模式 stack 有值）+ seed1337 warring → 首撞呼叫鏈：
```
own_granary_tile ← effective_holding ← effective_food ← NeedOracle._self_use("food")
  ← need_keep ← TradeValuation.reserve:91 ← interaction_system._attempt_barter:990
  ← _resolve_market ← _try_interact ← process_on_move ← _step4_resolve_interactions ← advance_tick
```
**根**：`reserve(team, res, leader_values, state = null)` 的 `state` **DEFAULT null**；`_attempt_barter` 呼 `reserve` 時傳了 `leader_vals(state, a)` 卻**漏傳第 4 arg `state`** → reserve 內 `state=null` → `need_keep(null)` → `_self_use(null,"food")` → `effective_food(null)` → `own_granary_tile(null)` 的 `state.world` 崩。

## ★onset 訂正（推翻假說）
crash **onset 非 day15**（那是 measurer 觀測窗）、**實為 day0.8**（tick199 首次 barter）。是 **mid-sim barter 常態路徑**（**非** Probe-gated、**非** teardown/stale-ref、**非** specimen）——plain warring baseline（fix stashed）於 tick199 即崩、已對照確認。

## T2 根修（state threading、非盲 guard）
`_attempt_barter`:990（give_res）+ :997（pay_res）兩 `reserve` 呼點**補傳 `state`**。
- **own_granary_tile 本體零改**（不加遮 silent-undercount 的頭 guard；[[feedback_symptom_vs_root]]）。
- **分類=補傳型**：post-fix vs pre-fix baseline fp 於 seed1337 1000t **byte-identical `728d62ef`** → 修的是 crash + error-storm + silent `effective_food` undercount（觀測完整性）；seed1337-1000t 窗內**無 fp 行為變**（granary-food-barter 差異未觸發分岔；長窗/他 seed 可能微分岔=正確 undercount 修、benign）。
- **★窮盡其他漏傳 state 呼點**（§4）：`_calc_reserve`:667=**死碼**（零 caller）；`decision_context`:335=**武器**（非食、`_self_use` 非食分支不觸 own_granary=安全）；`player_trade`:14=**玩家路徑**（headless 無玩家=非 live）。runtime trace 到 day16 **唯一 live null 源=barter 兩呼點**。

## T3 outpost_owner reason 永久 tap 轉正
`phase3_longterm_story_audit_bed`：measurer 臨時 diag（`owner_reason_by_team`：team→最近 `set_owner` reason、last-write-wins 同 OutpostOwnerBank 語意）→ **常駐 schema**。純記錄、無 RNG、無 mutation → determinism 不破。

## 驗（gate 對照 spec §3）
| gate | 結果 |
|---|---|
| `own_granary_null_caller_test`（新 TDD） | **3/3 PASS**：①站家隊 `effective_food` 含糧倉=100 ②`reserve(food,state)` granary-aware 不崩 ③`_attempt_barter` 端到端不崩（pre-fix 此處崩） |
| ①無 own_granary null crash | post-fix **0 錯** across **3360t+**（day0.8→day14、多 run）；pre-fix baseline tick199 崩（對照確認）。★full 12mo horizon → measurer |
| ②根=caller diff 證 | `interaction_system.gd` **2 行**（+state）；`resource_system.gd`/`own_granary_tile` **零改** |
| ③`effective_food` 含糧倉 | test PASS（=100） |
| ④determinism | seed1337 三跑 **byte-identical=`728d62ef`**（post-fix 自身；且 **== pre-fix baseline** = 補傳型） |
| ⑤constitution | **PASS 75** |
| headless 0-new | 分支 fail-set **== d1451fa7 baseline fail-set**（8 筆 pre-existing、逐筆對照相同、my change **零新增**） |

## ★measurer 需量測（bounded gate）
1. **full 12mo horizon crash-confirm**：我 detach/wrapper 長 run **皆 flaky 提早死**（day14 附近靜默終止、**日誌 0 own_granary 錯**=tooling reaping 非 code；spec §1 亦記需 godot-detach 撐 error-storm）。請 measurer 用穩定長 run 覆 12mo horizon 確認零 crash。
2. **owner_reason_by_team dump 值合理**（camp/takeover/capture 分布，T3）。

## 路
你 merge-gate 硬讀（根=caller state threading 非 guard + 補傳型 determinism + own_granary 零改）→ measurer bounded（12mo crash-confirm + T3 dump 值）→ 綠 merge → S2（L0 階梯）。地基 KEEP。
