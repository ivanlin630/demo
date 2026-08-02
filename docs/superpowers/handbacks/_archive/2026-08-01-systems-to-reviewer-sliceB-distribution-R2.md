---
from: systems
to: reviewer
status: consumed
topic: "[R² 甲=SLICE B分配政策HOW spec設計審(dispatch前必過)·spec:docs/superpowers/specs/2026-08-01-logistics-slice-B-lord-distribution-policy-HOW.md·審核心seam:①deficit偵測(領主掃自有resident-teams runway<閾)②_distribute_candidates(仿_deliver_candidates,util=deficit×persona義氣放大/貪婪衰減,競argmax對trade-util)③DELIVER終點擴充(interaction_system _resolve_market_at_outpost加resident-DELIVER分支,直注food入resident pool無market_order無支付)④unrest耦合(持續deficit→UnrestBank.add,fed→reduce,餵現成defection≥20)·審點:憲法WEIGH非GATE?感知鐵律(讀本勢力自有居民deficit=intra-faction合法非god-view敵情)?約束1走同一convoy原件非平行搬運?tap全接(distribute util per-option/DELIVER量/deficit runway/unrest源)?dev-verify硬斷夠?·剝削A/B fork並行呈blueprint裁,審seam本體不blocked"
---

# R² 甲 SLICE B 分配政策 HOW spec 設計審（dispatch 前必過）

spec：`docs/superpowers/specs/2026-08-01-logistics-slice-B-lord-distribution-policy-HOW.md`

## 審核心 seam（4 元件）
1. **deficit 偵測**：領主掃自有 resident-teams，runway=`(team_food+local_granary)/(pop×burn)` < `DISTRIB_DEFICIT_DAYS`。
2. **`_distribute_candidates`**（仿 goal_resolver `_deliver_candidates`:125）：util=`deficit_severity × HONOR_WEIGHT(honor,greed)`（義氣放大/貪婪衰減），競 argmax 對 trade-util，GOAL_UTIL_CAP 沿用。
3. **DELIVER 終點擴充**（interaction_system `_resolve_market_at_outpost`:731）：resident-DELIVER 分支，直注 food 入 resident team pool、**無 market_order/無支付/無 reserve**（純施捨轉移）。
4. **unrest 耦合**：resident 持續 deficit→`UnrestBank.add`、fed→`reduce`，餵現成 `unrest_turns≥20→event_faction_defect`。

## ★審點（我要你戳的）
- **憲法 WEIGH 非 GATE**？persona 是否只 weigh util（貪婪領主 loyalty 崩仍可發、義氣領主自斷糧讓位），無硬 gate 攔死分配？
- **感知鐵律**？分配決策讀「本勢力自有居民 deficit」＝intra-faction 自有後勤狀態（合法知情）、非 god-view 讀敵隱藏態——這推理成立嗎？有無隔空作用？
- **★約束1（統一搬運脊椎）**？分配真走**同一 convoy 原件**（FETCH→OUTBOUND→DELIVER→RETURN）、DELIVER 只是新終點分支，非另刻平行搬運路？
- **全量暫態可觀測性（憲法）**？新 decision（distribute util per-option）/resource move（DELIVER 量）/state（deficit runway、unrest 增減源）是否全接 tap？有無 tap-gap 讓 QA 判官盲？
- **dev-verify 硬斷夠嗎**（§3）？distribute 真 fire / 剝削真餵 unrest / persona 分岔翻轉 / determinism。

## note
- **剝削 A/B fork（§6）並行呈 blueprint 裁**（A=居民付coin大 / B=機會成本本spec採）。**審 seam 本體不被 fork blocked**（fork 只影響定價子部、核心 seam A/B 共用）。
- CLEAN → 我 dispatch（待 blueprint A/B confirm）。有洞 → 回 `to:systems`。
