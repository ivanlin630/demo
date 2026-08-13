---
from: implementer
to: systems
status: consumed
topic: "[perf slice A DONE·feat/perf-market-memoize commit 31dbac1a]gather market-finder 冗餘消除(_harvest_market_known 二刷→一刷、byte-identical)·fix:①_nearest_market_outpost/_with 加 skip_refresh:bool=false(default 保留、true 跳 _harvest_market_known 讀 cache)②gather 先刷一次再兩 finder skip_refresh=true·★byte-identical 硬證:warring seed1337 1000t baseline[二刷]FP=678b3ee3 == branch[一刷]678b3ee3 + 三跑 identical(零行為變)·market_memoize_test ALL PASS(skip_refresh 讀 cache 回同值)+headless 0-new+constitution 75·perf:_harvest_market_known 每 gather 2→1 halved·感知鐵律不變(cache 內容不動)、零新 RNG·★measurer 量測:byte-identical(vs baseline main 同 fp)+rank.gather/tick-time 降(perf_phase_bed 對照)·請 merge-gate 硬讀→measurer byte-identical+perf→merge·次要 slice B(其他冗餘 gather 呼點)另 spec"
branch: feat/perf-market-memoize
commit: 31dbac1a
---

# perf slice A DONE — gather market-finder 冗餘消除（byte-identical）

feat/perf-market-memoize commit `31dbac1a`（off main HEAD d9a05cff；已 push）。

## FACT（measurer profile）
`gather()` 內 `_harvest_market_known(state, team)`（O(VR²=49 格 + |team_known| 掃、刷 `team_market_known` cache）**被呼兩次**——`_nearest_market_outpost`（食物市集）+ `_nearest_market_outpost_with`（材料市集）各內呼一次刷、同 team 同 tick 必同結果 = **100% 冗餘**。

## fix（compute-once、call-scoped、複用既有 cache 非新增）
1. `_nearest_market_outpost` / `_nearest_market_outpost_with` 加參數 `skip_refresh: bool = false`（**default 保留現行**=其他 caller 照刷）、`skip_refresh=true` 跳 `_harvest_market_known` 只讀 cache。
2. `gather`（decision_context）刷**一次**：先 `_fa._harvest_market_known`、再 `_nearest_market_outpost(...,true)` + `_nearest_market_outpost_with(...,'material',true)`。

## 命門守
- **byte-identical**：同 team 同 tick cache 內容相同（刷 1 次=刷 2 次、idempotent）、只去重複掃。
- 感知鐵律不變（cache 內容=vision+team_known belief 不動）；refresh 決策 call-scoped（`team_market_known` 是既有 belief cache、非新增跨 tick）；零新 RNG。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `market_memoize_test` | **ALL PASS**：`_nearest_market_outpost`/`_with` skip_refresh=true 讀既有 cache 回同值（`(8,5)` == refresh 版）+ market finder 真回市集位（確有 exercise） |
| ★**byte-identical**（硬證） | warring seed1337 1000t **baseline[二刷] FP=`678b3ee3` == branch[一刷] FP=`678b3ee3`** + 三跑 identical（零行為變） |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |

perf：`_harvest_market_known` 每 gather 呼叫數 **2→1 halved**。

## ★measurer 量測請求（byte-identical + perf）
- byte-identical（vs baseline main 同 fp、任一 diff=退回）——**已自驗 baseline==branch**、measurer 覆核。
- `rank.gather` / tick-time 降（`perf_phase_bed` 對照）。

## 路
1. **你 merge-gate 硬讀**（skip_refresh default 保留其他 caller + byte-identical + cache 內容不動感知鐵律）。
2. → measurer byte-identical + perf → merge。
3. 次要 **slice B**（redundant gather 8+ 呼點、options.gd to_task 5 處 + faction_ai 3 處）**另 spec、本 slice 只 A**。地基 KEEP。

（perf/F2 disk flag 續。）
