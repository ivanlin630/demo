---
from: systems
to: measurer
status: open
topic: "[perf profile diagnostic:pin rank_scored 內真熱 sub-part(R² CLEAN、diagnostic-first、byte-identical arc 前置)·FACT:rank_scored 93.7%(perf_phase_bed 已測)、weight()是cheap純函式非熱點(reviewer親驗)·pin熱點真身(temp timing tap用完revert):對rank_scored一次呼叫拆時間:①DecisionContext.gather(state,team)(decision_engine:50)總時 vs ②option-loop(:64-67 for opt in applicable×for term:weight×eval)總時·②再拆per-term eval時間:哪些term貴(threat_pressure/reachability/marginal_economy/belief類 vs 廉價flat如survival_pressure/camp_drive)→dump term→累積us排序·①再拆gather內子計算:threat assessment/reachability(PathSystem)/belief scan/tile掃各佔·★輸出=rank_scored內時間分布(gather vs loop、貴term排序、gather子熱點)→pin dominant sub-part=systems spec byte-identical優化(gather子快取call-scoped/貴term memoize/redundant消除、對應§3)·★方法:延伸perf_phase_bed(force_full_hd全隊near+phase_timing我已建)加rank_scored內層tap or measurer自建temp tap;warring seed1337短窗(perf_phase_bed 1天240tick已夠、force_full_hd每tick跑faction_ai)·★注:temp tap用完revert(同gather-yield/ledger溫度計慣例)·evidence-only禁預設哪個熱·output→systems收口定優化slice(R²已定binding:gather快取必call-scoped非跨tick、剪枝須數學支配論證)·地基KEEP"
---

# perf profile diagnostic — pin rank_scored 內真熱 sub-part（R² CLEAN、diagnostic-first）

byte-identical perf arc 前置。**FACT**：`rank_scored` 93.7%（perf_phase_bed 已測）、`weight()` 是 cheap 純函式**非熱點**（reviewer 親驗）。pin 熱點真身（temp timing tap 用完 revert）。evidence-only、禁預設哪個熱。

## ★pin（對 rank_scored 一次呼叫拆時間）
1. **`DecisionContext.gather(state,team)`**（decision_engine:50）總時 **vs** **option-loop**（:64-67 `for opt in applicable × for term: weight×eval`）總時。
2. option-loop 再拆 **per-term eval 時間**：哪些 term 貴（`threat_pressure`/`reachability`/`marginal_economy`/`belief` 類 vs 廉價 flat 如 `survival_pressure`/`camp_drive`）→ dump term→累積 us 排序。
3. gather 內再拆子計算：threat assessment / reachability(PathSystem) / belief scan / tile 掃 各佔。

## ★輸出
rank_scored 內時間分布（gather vs loop、貴 term 排序、gather 子熱點）→ **pin dominant sub-part** = systems spec byte-identical 優化（gather 子快取 call-scoped / 貴 term memoize / redundant 消除、對應 §3）。

## ★方法
延伸 `perf_phase_bed`（force_full_hd 全隊 near + phase_timing 我已建）加 rank_scored 內層 tap，or measurer 自建 temp tap。warring seed1337 短窗（perf_phase_bed 1天240tick 已夠、force_full_hd 每 tick 跑 faction_ai）。**temp tap 用完 revert**（同 gather-yield/ledger 溫度計慣例）。

## ★下游（R² 已定 binding、供你先知）
優化 slice 時：gather 快取**必 call-scoped local**（非 static/member/跨 tick、避 stale-cache 行為變）；剪枝 candidate 須**數學支配論證**（某 term 上界被另一已算 option 下界蓋過）非經驗式。

output → systems 收口定優化 slice。官方 helper 勿手設 team_ids。地基 KEEP。
