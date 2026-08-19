---
from: systems
to: implementer
status: consumed
topic: "[dispatch perf刀3=alloc-churn sweep(hot-path FactionAISystem.new() finder靜態化)·base main 3f40745e·spec=2026-08-18-perf-phase2-cut3-alloc-sweep-HOW.md R²-CLEAN(reviewer親重跑count 41/30精確吻合+2 instance欄usage全dispatch類零finder+額外抽驗_find_own_outpost 9×最高頻完全純函式零instance鏈靜態化零風險)·★核心刀A同族:hot-path finder(state+team→target無instance state)改static func→replace FactionAISystem.new().<finder>為FactionAISystem.<finder>免per-call alloc·scope:hot決策路30 site(options15/goal_resolver7/need_oracle4/decision_context4)、_find_own_outpost(9×)最大量優先·★靜態化前逐finder驗無instance state(不碰_last_site_sig/_last_dispatch_fail、不呼別的instance method鏈間接碰state;reviewer已驗_find_own_outpost純、其餘你逐個查鏈)、某finder內部呼instance method鏈→順鏈靜態化or該finder保new()不硬拆·compiler強制static無法碰instance=編譯期保statelessness·★憲法gate硬:byte-identical 3跑機器證(同seed StateFingerprint精確match)+constitution+無新常數·★measurer quantify n≥2 noise-check(刀D單跑噪聲誤判教訓、須多跑分離真效果)·★止損:quantify落噪聲(<run-noise)→回報perf arc收官banked刀A;顯著→merge→刀4 C·TDD:①靜態化finder呼==原instance呼逐finder同值②hot path無FactionAISystem.new()(grep證、剩dispatch類合法)③byte-identical 3跑④constitution·worktree feat/perf-cut3-alloc·與農業平行·完→handback附measurer·地基KEEP"
---

# dispatch perf 刀3=alloc-churn sweep（hot-path finder 靜態化）

spec=`docs/superpowers/specs/2026-08-18-perf-phase2-cut3-alloc-sweep-HOW.md`（**R²-CLEAN**、reviewer 親重跑 count + 抽驗 `_find_own_outpost` 純）。base=main `3f40745e`。與農業平行。

## ★核心（刀A 同族）
hot-path finder（state+team→target、無 instance state）改 **static func** → replace `FactionAISystem.new().<finder>` 為 `FactionAISystem.<finder>` 免 per-call alloc。
- **scope**：hot 決策路 30 site（options15/goal_resolver7/need_oracle4/decision_context4）、`_find_own_outpost`(9×) 最大量優先。
- **★逐 finder 驗無 instance state**（不碰 `_last_site_sig`/`_last_dispatch_fail`、不呼別的 instance method 鏈間接碰 state；reviewer 已驗 `_find_own_outpost` 純、其餘你逐個查鏈）；某 finder 內部呼 instance method 鏈→順鏈靜態化 or 該 finder 保 new()（不硬拆）。
- compiler 強制 static 無法碰 instance=編譯期保 statelessness。

## ★憲法 gate（硬）
byte-identical 3 跑機器證（同 seed StateFingerprint 精確 match）+ constitution + 無新常數。

## ★measurer quantify（n≥2 noise-check）
刀D 單跑噪聲誤判教訓、須**多跑分離真效果**。**★止損**：quantify 落噪聲（<run-noise）→ 回報 perf arc 收官（banked 刀A）；顯著→merge→刀4 C。

## TDD
①靜態化 finder 呼==原 instance 呼逐 finder 同值 ②hot path 無 FactionAISystem.new()（grep 證、剩 dispatch 類合法）③byte-identical 3 跑 ④constitution。

worktree `feat/perf-cut3-alloc`。與農業平行。完 → handback 附 measurer。地基 KEEP。
