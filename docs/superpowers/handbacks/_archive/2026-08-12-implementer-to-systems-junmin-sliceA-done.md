---
from: implementer
to: systems
status: consumed
topic: "[军民混编 Slice A DONE·feat/junmin-militia-slice-a commit c3cf3df8]guard_ratio 照妖鏡 de-patch(離散 tag-gated 死常數→連續人格化)+ belief-threat 去 god-view、行為變 slice·①guard_ratio=clampf(BASE0.1+慎重×0.2+好戰×0.15[責任/尚武 proxy 人格非 tag]+belief_threat_norm×0.25−attack×0.1,0.05,0.5)禁離散/tag-gated 死值·②新 _max_belief_threat(ThreatAssessment.score max over team_discovered hostiles 感知鐵律)取代 _has_hostile_within god-view、finding⑥ 純軍團守衛也走 belief·★_has_hostile_within(god-view 唯一 caller)已除·自我限縮不碰 pool_of/TAG_PRODUCE/uses_unified 承重牆·★驗:junmin_guard_test ALL PASS(①連續人格分化 machine-demonstrate[慎重0→1 guard 0.175→0.375 單調連續非離散5值;高慎重>低;高好戰>低]②belief-threat 升守0.275→0.5+★god-view 除[未discovered 敵鄰格→guard 不變不偷看真位置]③攻擊降④bounded[clamp0.5/floor0.05 夜襲免疫不裸奔])+headless 0-new(S7 Task6 更新連續+belief 語意)+constitution 75+active_promotion/named_scarcity_ab regression PASS+determinism 3-run byte-identical(warring seed1337 752912f9)·★fp 前後對照 LIVE(warring baseline[discrete+god-view]839256e3→branch[continuous+belief]752912f9 DIVERGED、guard_peak 0→0.5)·consumers(get_guards→camp vision→night-raid immunity/夜哨/rest_mult)讀 ratio 不變只改計算 floor 保不裸奔·★下游 re-measure(連續分化率+belief 遠/stale 感知+consumers 不漏)=measurer·請 merge-gate 硬讀(核 de-patch 連續無死值殘留+belief-threat 無 god-view+軍團有感知+consumers 接不漏+bounded)→QA→merge→blueprint·★Slice B 另批不做"
branch: feat/junmin-militia-slice-a
commit: c3cf3df8
---

# 军民混编 Slice A DONE（guard_ratio 照妖鏡 de-patch + belief-threat 去 god-view、行為變 slice）

feat/junmin-militia-slice-a commit `c3cf3df8`（off main HEAD abab7273；已 push）。★自我限縮：**不碰 `pool_of`/`TAG_PRODUCE`/`uses_unified` 承重牆**（Slice B 另批）。

## §HOW-binding 兩塊
### ① guard_ratio 照妖鏡 de-patch（離散死常數 → 連續人格化）
`_update_guard_ratio`（faction_ai:3069）離散 0.1/0.15/0.2/0.35/0.4 tag-gated 死常數 → **連續**：
```
guard_ratio = clampf(GUARD_BASE(0.1) + 慎重×0.2 + 好戰×0.15 + belief_threat_norm×0.25 − attack_commit×0.1, 0.05, 0.5)
```
- 慎重（守衛保守）+ 好戰（**責任/尚武 proxy、人格非 tag**）+ belief-threat（感知威脅）+ 攻擊-commit（前線投入降）。**禁離散跳變/tag-gated 死值**。
- consumers（`get_guards`→camp vision→`_check_night_raid` 夜襲免疫 / 夜哨 / `rest_mult`）讀 ratio 不變、只改計算；**floor 0.05** 保軍團威脅時 guard 升非裸奔（finding⑤ night-raid immunity 接不漏）。

### ② belief-threat（感知鐵律、去 god-view）
新 `_max_belief_threat`（`ThreatAssessment.score` max over `team_discovered` hostiles、同勢力/positionless→0）取代 `_has_hostile_within` god-view。**finding⑥**：純軍團守衛 threat 也走 belief（discovered gate + belief_pos、非全知）。★`_has_hostile_within`（god-view、唯一 caller=本函式）**已除**。

## 命門
genuine 非死常數（guard 由 慎重/好戰/belief-threat 人格湧現）、bounded[0.05,0.5]、感知鐵律（threat 全 belief 無 god-view）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `junmin_guard_test` | **ALL PASS**：①連續人格分化 **machine-demonstrate**（慎重 0→1 guard **0.175→0.375 單調連續**、非離散 5 值；高慎重 0.355>低 0.195；高好戰 0.335>低 0.215）②belief-threat 升守（0.275→0.5）+ ★**god-view 除**（未 discovered 敵鄰格 → guard=無威脅值、不偷看真位置）③攻擊降（0.175<0.275）④bounded（極端 clamp 0.5 / floor 0.05） |
| headless | **0-new**（S7 Task6 `_test_update_guard_ratio` 更新為連續+belief-threat 語意 + god-view 除案） |
| constitution_gate | **PASS sites=75** |
| regression | `active_promotion` + `named_scarcity_ab` **ALL PASS** |
| determinism | **3-run byte-identical**（warring seed1337 1000t FP `752912f9`；ThreatAssessment 純算術無新 randf） |

## ★fp 前後對照 LIVE（warring seed1337、baseline[discrete+god-view] vs branch[continuous+belief]）
| metric | baseline | branch |
|---|---|---|
| **FP** | `839256e3` | `752912f9` **DIVERGED(intended)** |
| guard.ratio_peak | 0（tap 無） | **0.5**（連續 guard 值 vs 舊離散 + belief-threat vs god-view） |

## ★下游 re-measure（measurer realistic、硬數字非預設）
guard 連續人格分化率（慎重高守衛保守/好戰高多守）+ belief-threat 遠/敵 stale/positionless 感知（無 god-view leak、軍團也有感知）+ consumers 不漏（night-raid immunity/夜哨/rest_mult 三處 sensible）+ bounded = **measurer 職**。

## 路
1. **你 merge-gate 硬讀**（核 de-patch **連續 genuine 無死值殘留** + belief-threat **無 god-view** + 軍團有感知 + consumers 接不漏 + bounded）。
2. → QA → merge → blueprint 推用戶。
3. ★**Slice B（團型梯度 + pool 分數化 + guns-vs-butter + 承重牆 uses_unified decouple）另批不做**（須先 spike 定 decouple 法）。地基 KEEP。

（perf/F2 disk flag 續。）
