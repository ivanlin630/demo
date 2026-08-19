---
from: systems
to: implementer
status: open
topic: "[dispatch §4b(三動機+擴點純邊際帳+overflow margin 決策化)·base main(含 §4a f003ebe5)·spec=2026-08-20-settlement-S4b-expansion-marginal-HOW.md(含 §5 R²delta 訂正)·R²=CLEAN+1 必查項(已寫進 spec、公式在下)·★T1 新 engine option『擴點』:applicable=只物理可行性(has_own_outpost + _evaluate_new_outpost_location:4058 回有效 pos + 母隊 pop 足以派子隊[沿用 _dispatch_builder 既有守衛不新增] + 非玩家);to_task=delegate 既有路(回 {delegate:true, build_type, target:pos, settler:…}→由既有 _dispatch_builder:3617 執行、reviewer 親查該路【不經 try_set、六道 guard 全在前、唯一寫入在最後一行 all-or-nothing】=無 §4a 那種 race、不需額外 commit-hook);priority 欄標 PRIO_DISPATCH+why-comment(§4a invariants 契約)·★★必查項=util 精確公式(R² 訂正、別自己猜):【家內邊際 = _inflow_est(家est, pop=team.population) − _inflow_est(家est, pop=team.population − settler)】=鏡射既有 migrant_marginal(marginal_economy:35-43)的差分 idiom、方向相反(人力離開);【分點期望邊際 = _inflow_est(候選地 est)】、候選地 est 用既有 camp_target_est pattern(decision_context:323-327 VillageEstimate.make(候選 tile.terrain, 1, 0, 擬派 settler 數));【建置成本 = settler 抽離產能 + 工期期間分點零產出(既有 construction ticks)】;util ∝ max(0, 分點期望邊際 − 建置成本 − 家內邊際)、人格只 modulate 既有權重(野心/慎重)·★ctx.idle_labor 【不進 util 公式本體】、只做 applicable 篩選/早退優化(原稿手揮版量綱不符=會逼你發明換算係數=新旋鈕、已移除)·★T2 overflow margin:check_overflow_for_team(population_system:24)觸發改 population > cap × POP_OVERFLOW_MARGIN(TEST VALUE 1.15、唯一容許的新常數)、不刪保底·T3 軍事佔位不建·TDD:①有家+有候選才 applicable(無家團不 fire)②util 全走 _inflow_est 差分(code 無任何手寫換算係數=零新旋鈕、grep 自驗)③擴點 committed 後 task_priority=PRIO_DISPATCH④margin:pop 超 cap 但未達 cap×1.15→機械不 fire;超過→仍 fire(保底在)⑤既有 slice 不破(紮營/紮根/S1/agri)·gate:三動機分化+overflow 機械觸發→0+pop 不卡 cap+零新常數 code-read+§4a deferred empirical 兩項(瀕餓 isolated/壓境區中斷-續建)+determinism+constitution 75 不回升+headless 0-new+fp intended-change 標·worktree feat/settlement-s4b·完→handback to:systems 附新 fp·地基KEEP"
---

# dispatch §4b（三動機 + 擴點純邊際帳 + overflow margin 決策化）

spec=`docs/superpowers/specs/2026-08-20-settlement-S4b-expansion-marginal-HOW.md`（含 §5 R²delta 訂正）。R²=**CLEAN + 1 必查項**（已寫進 spec、公式在下）。base=main（含 §4a `f003ebe5`）。

## ★T1 新 engine option「擴點」
- **applicable（只物理可行性）**：`has_own_outpost` + `_evaluate_new_outpost_location`(faction_ai:4058) 回有效 pos + 母隊 pop 足以派子隊（**沿用 `_dispatch_builder` 既有守衛、不新增**）+ 非玩家。
- **to_task=delegate 既有路**：回 `{delegate:true, build_type, target:pos, settler:…}` → 由既有 `_dispatch_builder`(:3617) 執行。**reviewer 親查該路不經 `try_set`、六道 guard 全在前、唯一世界寫入在最後一行=all-or-nothing** → **無 §4a 那種 race、不需額外 commit-hook**。
- `priority` 欄標 **`PRIO_DISPATCH` + why-comment**（§4a invariants 契約）。

## ★★必查項=util 精確公式（R² 訂正、**別自己猜**）
- **家內邊際** = `_inflow_est(家est, pop=team.population) − _inflow_est(家est, pop=team.population − settler)`
  =**鏡射既有 `migrant_marginal`(marginal_economy:35-43) 的差分 idiom、方向相反**（人力離開）。
- **分點期望邊際** = `_inflow_est(候選地 est)`；候選地 est 用**既有 `camp_target_est` pattern**（`decision_context:323-327`：`VillageEstimate.make(候選 tile.terrain, 1, 0, 擬派 settler 數)`）。
- **建置成本** = settler 抽離產能 + 工期期間分點零產出（既有 construction ticks）。
- `util ∝ max(0, 分點期望邊際 − 建置成本 − 家內邊際)`；人格只 **modulate 既有權重**（野心/慎重）。
- **★`ctx.idle_labor` 不進 util 公式本體**、只做 applicable 篩選/早退優化（原稿手揮版**量綱不符**[手數 vs 食物/日]=會逼你發明換算係數=**新旋鈕**、已移除）。

## ★T2 overflow margin
`check_overflow_for_team`(population_system:24) 觸發改 `population > cap × POP_OVERFLOW_MARGIN`（**TEST VALUE 1.15**、**唯一容許的新常數**）、**不刪保底**。

## T3 軍事要地=佔位不建。

## TDD
①有家+有候選才 applicable（無家團不 fire）②**util 全走 `_inflow_est` 差分**（code 無任何手寫換算係數=零新旋鈕、grep 自驗）③擴點 committed 後 `task_priority==PRIO_DISPATCH` ④margin：pop 超 cap 但未達 `cap×1.15` → 機械不 fire；超過 → 仍 fire（保底在）⑤既有 slice 不破（紮營/紮根/S1/agri）。

## gate
三動機分化 + `overflow_split` 機械觸發→0 + pop 不卡 cap + 零新常數 code-read + **§4a deferred empirical 兩項**（瀕餓 isolated / 壓境區中斷-續建）+ determinism + **constitution 75 不回升** + headless 0-new + fp intended-change 標。

worktree `feat/settlement-s4b`。完 → handback to:systems 附新 fp。地基 KEEP。
