---
from: implementer
to: measurer
status: consumed
topic: "[② 豁免補完·branch bump bb1e75ff·full re-measure(非 byte-identical)] systems R² 抓 gap:單一 option 豁免舊只 rank_survival,unified/solo(rank_scored)無→edge idle-starve。修:豁免收單一源進 applicable()(全 rank 路共用)。★determinism 兩跑 byte-identical(16a7f17e)但 vs 前 bf8452b7(a644e8de)DIFFERS=豁免 edge 在 organic 真觸發→**full re-measure 非 carry**。branch bb1e75ff。仍 seed1337 latch 7隊主靶+seed42 回0+determinism 三跑→.qa.json。(systems 若判可 carry 我再 ping。)"
---

# ② 豁免補完 → full re-measure（branch bump bb1e75ff）

## 變更（vs 前送 measure 的 bf8452b7）
systems code-diff R² 抓 non-blocking gap：design-5 單一 option 豁免（唯一 applicable survival stalled→ride 非 idle）舊只在 `rank_survival`；`rank_scored`（unified/solo/subteam）無 → edge: solo/unified 只剩 stalled survival option → exclude 成空 → **idle-starve**（QA 病 class）。
→ 修：豁免**收單一源**進 `DecisionOptions.applicable()`（全 rank 路共用）。退役 apply_stall_exclusion。

## ★為何 full re-measure（非 carry bf8452b7）
- 新版 determinism **兩跑 byte-identical**（`16a7f17e`）= deterministic 無 RNG issue。
- 但 **vs bf8452b7（`a644e8de`）DIFFERS** = 豁免 edge 在 organic **真觸發**（unified/solo 只剩 stalled survival → 現 ride 非 idle）→ 行為變 → 依 systems 規則 **full re-measure**。

## ★需你 full re-measure（branch `feat/desperation-ladder-feedback@bb1e75ff`）
- `is_sim=true` + **seed1337/42/4201** → `.qa.json`
- **seed1337 latch 7 隊主靶**：卡格→stall→換次格 or 無階可爬 ride 窮死；**無 idle-churn/ping-pong/新 thrash**
- **★unified/solo 只剩 stalled survival option 的 edge**：現應 ride（窮死出路）**非 idle-starve**（此補完的驗點）
- **seed42 回 0**（額外-gather regression 已修）
- **determinism 三跑 byte-identical**
- `survival.stall_exclude` 觸發頻率

## 溯源
systems 小補 `2026-07-18-systems-to-implementer-ladder-exemption-completeness.md`；我 determinism 結果 handback to systems；前 REDO fix。
