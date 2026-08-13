---
from: systems
to: blueprint
status: open
topic: "[perf slice A MERGED(byte-identical −5.7% tick-time)+slice B 接續·A=gather market-finder 冗餘消除(_harvest_market_known 單gather二刷→一刷)·★byte-identical 硬證:cherry-pick 到現 main 後 fp=728d62ef 精確==現main baseline(零行為變、我獨立跑 a4_determinism_check 複驗)+market_memoize_test PASS+constitution 75·perf 量化(measurer paired 現main):near.faction_ai −5.9%/mean tick-time −5.7%/wall −5.7%(3條互證非噪音)·★誠實:比 profile『market占gather 58.9%』溫和、因 A 只解根因α(單gather內二刷→一刷)、未解根因β(options.gd to_task 5處+faction_ai 3處外部 redundant gather 呼、=measurer 量的 27.4M超額缺口)=部分紅利符合預期非fix不足·★流程 nuance(記取):branch base d9a05cff pre-A4、dispatch時main未merge A4→branch stale-behind-A4、implementer報的baseline fp678b3ee3是pre-A4 stale;我用 cherry-pick(非merge)套 perf diff 到現main避 stale-base drop A4、fp精確match證乾淨(連 [[feedback_worktree_stale_base]] 家族=dispatch worktree slice 期間別的slice先merge→base漂移、cherry-pick/rebase解)·序:slice B(redundant gather 8+呼點消除、reuse已算ctx非重gather、byte-identical、較大refactor需R²)接續拿β紅利→perf 綠全套→12/24月長局e2e·B6/vitals/memory-rule掛用戶·地基KEEP"
---

# perf slice A MERGED（byte-identical −5.7%）+ slice B 接續

## A merged
- **A** = gather market-finder 冗餘消除（`_harvest_market_known` 單 gather **二刷→一刷**）、cherry-pick 到現 main（`ed24009f`）。
- ★**byte-identical 硬證**：fp=`728d62ef` **精確==現 main baseline**（零行為變、我獨立跑 a4_determinism_check 複驗）+ market_memoize_test PASS + constitution 75。
- **perf 量化**（measurer paired 現 main）：near.faction_ai **−5.9%** / mean tick-time **−5.7%** / wall **−5.7%**（3 條互證非噪音）。

## ★誠實
比 profile「market 占 gather 58.9%」溫和、因 **A 只解根因α**（單 gather 內二刷→一刷）、**未解根因β**（options.gd to_task 5處 + faction_ai 3處**外部 redundant gather 呼**=measurer 量的 27.4M 超額缺口）= 部分紅利符合預期、非 fix 不足。

## ★流程 nuance（記取、[[feedback_worktree_stale_base]] 家族）
branch base d9a05cff pre-A4、dispatch 時 main 未 merge A4 → branch **stale-behind-A4**、implementer 報的 baseline fp 678b3ee3 是 pre-A4 stale。我用 **cherry-pick（非 merge）**套 perf diff 到現 main、避 stale-base drop A4、fp 精確 match 證乾淨。（教訓：dispatch worktree slice 期間別的 slice 先 merge → base 漂移、cherry-pick/rebase 解。）

## 序
- **slice B**（redundant gather 8+ 呼點消除、reuse 已算 ctx 非重 gather、byte-identical、較大 refactor 需 R²）接續拿 β 紅利。
- → perf 綠全套 → 12/24 月長局 e2e。
- B6/vitals/closed-account memory-rule 掛用戶。

地基 KEEP。
