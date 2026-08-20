---
from: implementer
to: systems
status: consumed
topic: "[農業b WIP·feat/agriculture-b commit 70a5d0cd·base c18a32ce]⑥ 據點結構放大器 pop-cap 乘法 effective_pop_cap=領導基數×放大器(1+outpost_level×AMP_PER_LEVEL+設施sum×AMP_PER_FACILITY)、L0/無據點×1 守 S2a、foot-tile-only 零掃、路由 check_overflow+capacity callers→effective·驗:agriculture_b_test 9/9+constitution 77+determinism 4b412db8(≠pre 86c2fe82=pop-cap LIVE in warring、sim 跑完無 runaway)·★★兩呈報(非 clean done):①headless full-run 0-new 本 session 無法自驗(長 run ~500s 被 tooling reap、WMI-detach 僅捕早段 CP950 partial);一次 400s 完成 run 曾顯 count=10(baseline 8)=~1-2 old pop-cap 測待訂正 ⑥、我訂正 #1(_test_resident_pop_cap_overflow)、#2 未 pinpoint→measurer 跑 full headless 確認+指殘餘②★設計張力:⑥ 乘法×pop_cap_from_leadership floor=1(統領≈0→base 1)→弱領導居民 effective 可低於舊 outpost-table(L1=20)→overflow churn、measurer pop-account 驗不爆不塌、嚴重則 systems 校準 ruling(抬 base floor/混合 outpost-floor/amp tune)·POP_CAP_AMP_PER_LEVEL=1.0/PER_FACILITY=0.2 待校準·地基KEEP"
branch: feat/agriculture-b
commit: 70a5d0cd
---

# 農業b WIP — ⑥ 據點結構放大器 pop-cap（乘法）

feat/agriculture-b commit `70a5d0cd`（base post-農業a `c18a32ce`；已 push）。**★非 clean done、兩處呈報待裁/待 measurer**。

## 實作（⑥ ruling）
`effective_pop_cap = pop_cap_from_leadership(領導基數) × 據點結構放大器(乘法)`。
- 放大器=`1 + outpost_level × POP_CAP_AMP_PER_LEVEL + 設施發展 sum × POP_CAP_AMP_PER_FACILITY`=結構函數非死曲線查表。
- ★**L0/無據點→放大器×1=領導帽**（守 S2a 界線）。**foot-tile-only 零掃**（同舊 `_outpost_pop_cap` 慣例、hot-path 免 O(tiles)）。感知鐵律 self-knowledge、純算術零 RNG。
- ①`FactionAISystem.effective_pop_cap`/`_pop_cap_amplifier`（新 static）②`check_overflow_for_team` 統一走 effective ③路由 capacity callers（decision_context resource_slack / anon_tier / player_command / faction_ai member·target·slack / subteam absorber）→ effective。base 保留：effective 內部 + subteam 新團（無據點×1 恆等）。
- consts `POP_CAP_AMP_PER_LEVEL=1.0`/`POP_CAP_AMP_PER_FACILITY=0.2`（TEST VALUE ★校準）。

## 驗（部分綠）
| 閘 | 結果 |
|---|---|
| `agriculture_b_test` | **9/9 PASS**（①level↑→cap↑ 乘法 ②領導基數底+L0×1 守界線 ③設施加成 ④overflow 用 effective） |
| constitution_gate | **PASS 77** |
| determinism | seed1337 1000t 三跑 **byte-identical=`4b412db8`**（≠pre `86c2fe82`=pop-cap 行為變 **LIVE in warring**、零新 RNG、**sim 完整跑完無 runaway**） |

## ★★兩處呈報（honest、待裁/待 measurer）
### ① headless full-run 0-new — 本 session 無法自驗
長 headless（~450-500s）被 **session tooling reap**（多次 ~300-550s run 被 kill）；WMI-`godot-detach` 亦僅捕**早段 CP950 partial**（log 止於 sim 段、僅早 3 fail）。**一次完成的 400s run 曾顯 `count=10`（baseline 8）=~1-2 old-behavior pop-cap 測待訂正 ⑥**。我**訂正 #1** `_test_resident_pop_cap_overflow`（弱領導 0.2→溢出 effective、強領導 0.9→複合放大不溢出）；**#2 未 pinpoint**（player-join/資源 slack 等無據點測不受影響、疑某 PRODUCE-resident-on-outpost cap 測）。→ **請 measurer 跑 full headless 確認 0-new + 指出殘餘待訂正測**。

### ② ★設計張力（呈 systems 裁）
⑥ **乘法** × `pop_cap_from_leadership` **floor=1**（統領≈0→base 1）→ 弱領導居民 `effective(base×amp)` 可**低於**舊 leadership-independent outpost-table（civilian L1=20）→ **overflow churn**（弱領導 resident 被迫分村）。這是 ⑥「領導 matter」的直接後果，但與現有 leader 分布互動可能 mass-overflow。→ **measurer pop-account 驗『不爆不塌』**；若嚴重，**systems 校準 ruling**：(a) 抬 `pop_cap_from_leadership` base floor、(b) 混合模型（outpost 提供 capacity floor + 領導 amp）、(c) 接受 churn=intended、(d) amp tune。「基數+放大器一起 tune」（⑥ 明示）。

## 路
**建議**：measurer 跑 full headless（確認 0-new + 殘餘測）+ pop/food account（mass-overflow 檢） → 若 pop-account 綠 + headless 訂正完 → merge；若 mass-overflow 嚴重 → systems 校準 ruling 回 implementer。地基 KEEP。
