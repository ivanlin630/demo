---
from: systems
to: blueprint
status: open
topic: "[军民混编 Slice A MERGED(998f5344)→ready 推用戶·guard 照妖鏡 de-patch+belief-threat 去 god-view 全鏈走完·★guard_ratio 離散 tag-gated 死常數(0.1/0.15/0.2/0.35/0.4)→連續人格化 clampf(BASE0.1+慎重×0.2+好戰×0.15+belief_threat_norm×0.25−attack_commit×0.1,0.05,0.5)=照妖鏡族 de-patch(genuine 人格+belief 湧現非死值)·★_has_hostile_within god-view(teams_within+live tile_pos 掃真位置)全除→_max_belief_threat(team_discovered belief+ThreatAssessment.score)、finding⑥ 純軍團守衛也走 belief(不再零感知)、感知鐵律達·★attack_commit 二元=世界狀態 situational(前線投入)非人格閘 legit·★驗收全鏈:spec R①+R²+systems merge-gate 硬讀 CLEAN+QA release CLEAN(親算 exact match caution0=0.175/caution1=0.375 單調、god-view 除 diff CONFIRM 舊函式+caller 整刪非換皮、consumers grep 全庫 2 處確認接不漏、bounded 四項拉滿=0.5 卡 clamp、floor0.05 夜襲免疫不裸奔)·憲法 PASS75+junmin_guard+regression ALL PASS+headless 1200t reproducible+determinism byte-identical+3-way merge CLEAN 僅 3 檔·★fp DIVERGED guard_peak 0→0.5·★Slice B(團型梯度+pool 分數化+guns-vs-butter 動員)=待承重牆 spike(uses_unified:2394 綁 TAG+~15 gate decouple 法)後你另 spec+R²、本批不做=下一步·序:你推用戶(Slice A:guard 決策從離散死常數→人格+belief 湧現、軍團有威脅感知不偷看真位置)+決 Slice B spike 啟否(承重牆 uses_unified decouple 法先探)·地基 KEEP"
---

# 军民混编 Slice A MERGED（998f5344）→ ready 推用戶

guard 照妖鏡 de-patch + belief-threat 去 god-view 全鏈走完。

## ★fix
- guard_ratio 離散 tag-gated 死常數（0.1/0.15/0.2/0.35/0.4）→ **連續人格化** `clampf(BASE0.1+慎重×0.2+好戰×0.15+belief_threat_norm×0.25−attack_commit×0.1, 0.05, 0.5)` = 照妖鏡族 de-patch（genuine 人格+belief 湧現非死值）。
- `_has_hostile_within` god-view（teams_within+live tile_pos 掃真位置）**全除** → `_max_belief_threat`（team_discovered belief + ThreatAssessment.score）、finding⑥ 純軍團守衛也走 belief（不再零感知）、**感知鐵律達**。
- attack_commit 二元 = 世界狀態 situational（前線投入）非人格閘 legit。

## ★驗收全鏈
spec R①+R² + systems merge-gate 硬讀 CLEAN + QA release CLEAN（親算 exact match caution0=0.175/caution1=0.375 單調、god-view 除 diff CONFIRM 舊函式+caller 整刪非換皮、consumers grep 全庫 2 處確認接不漏、bounded 四項拉滿=0.5 卡 clamp、floor0.05 夜襲免疫不裸奔）。憲法 PASS75 + junmin_guard + regression ALL PASS + headless 1200t reproducible + determinism byte-identical + 3-way merge CLEAN（僅 3 檔）。fp DIVERGED guard_peak 0→0.5。

## ★Slice B（下一步、本批不做）
團型梯度 + pool 分數化 + guns-vs-butter 動員 = 待**承重牆 spike**（`uses_unified:2394` 綁 TAG + ~15 gate decouple 法）後你另 spec + R²。

序：**你推用戶**（Slice A：guard 決策從離散死常數 → 人格+belief 湧現、軍團有威脅感知不偷看真位置）+ 決 Slice B spike 啟否（承重牆 uses_unified decouple 法先探）。地基 KEEP。
