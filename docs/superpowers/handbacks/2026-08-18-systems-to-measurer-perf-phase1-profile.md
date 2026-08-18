---
from: systems
to: measurer
status: open
topic: "[perf arc Phase1 細 profile(只量不改evidence-only禁edit、與settlement S2b gate平行不搶)·擴充perf_phase_bed既有FaiPhase markers往內鑽把93.7%(near.faction_ai=DecisionEngine.rank_scored per-team)拆開·Team step拆解各階段:①perception/state gathering②needs eval③candidate generation(applicable gates)④scoring(term×weight)⑤selection⑥execution各分支(movement-pathfinding/resource/event/message/faction-reaction)·每階段量:耗時+呼叫次數+candidates/evaluations量+重複world query偵測(同tick同query幾次=memo機會)+allocation熱點+『全體慢vs特定team/action慢』分布(per-team timing histogram+per-option execution timing)·短窗3-7天(上次成功經驗)·★output=hot-spot排行、每項標註『byte-identical-safe與否』(=兩道分類:安全道cache/memo/index/減alloc vs 行為影響道降頻/deferred)供blueprint帶用戶裁Phase2清單·★觀測禁耗global RNG+禁污染Probe(invariants §83、profiling markers須_begin/_end_observe或等價、on/off byte-identical)·evidence-only禁edit production邏輯(markers=temp instrumentation用完revert同你既有temp tap慣例)·出.measure.json落地path"
---

# perf arc Phase1 細 profile（只量不改、evidence-only）

與 settlement S2b gate **平行不搶**。上次 93.7%（near.faction_ai=`DecisionEngine.rank_scored` per-team）是粗天花板、這次**鑽進 faction_ai 內部拆開**。

## 擴充 perf_phase_bed FaiPhase markers 往內鑽
Team step 拆解各階段：①perception/state gathering ②needs eval ③candidate generation(applicable gates) ④scoring(term×weight) ⑤selection ⑥execution 各分支(movement-pathfinding/resource/event/message/faction-reaction)。

每階段量：**耗時 + 呼叫次數 + candidates/evaluations 量 + 重複 world query 偵測（同 tick 同 query 幾次=memo 機會）+ allocation 熱點 + 「全體慢 vs 特定 team/action 慢」分布**（per-team timing histogram + per-option execution timing）。

## ★output
hot-spot 排行、每項標註 **「byte-identical-safe 與否」**（=兩道分類：安全道 cache/memo/index/減 alloc vs 行為影響道 降頻/deferred）→ blueprint 帶用戶裁 Phase2 清單。

## 守則
- 短窗 3-7 天（上次成功經驗）。
- **★觀測禁耗 global RNG + 禁污染 Probe**（invariants §83：profiling markers 須 `_begin/_end_observe` 或等價、on/off byte-identical、否則觀測改被觀測物）。
- **evidence-only 禁 edit production 邏輯**（markers=temp instrumentation、用完 revert、同你既有 temp tap 慣例）。
- 出 `.measure.json` 落地 exact path。
