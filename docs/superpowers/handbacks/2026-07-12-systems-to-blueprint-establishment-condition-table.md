---
from: systems
to: blueprint
status: open
topic: [code審·零跑] 完整建國→established兩階段條件表—食物只是階段A一門;真根候選=path_ok可達獨立盟/7日盈餘/readiness≥0.7;probe indep.gate_fail_*已instrument直接指門
---

# 完整 established 條件表（零跑純讀，file:line）——兩階段門

established=0 因**兩階段門**，farming 只解階段 A 的一門（食物）。全鏈：

## 階段 A：獨立隊 → 組成 faction（`_evaluate_independent_strategy:1109`）
**建國 intent 須先贏 argmax**（:1197 `select_strategic_intent`，與致富/守成/防衛競爭；found_score=best_sub_util×(0.6+野心×0.6)+commitment :1174-1176）。且 `can_found`（:1183）**同時**滿足：
| # | 條件 | file:line | 常數 | farming 解了? |
|---|---|---|---|---|
| A1 | fid == -1 | :1183 | — | n/a |
| A2 | 野心 ≥ AMBITION_FOUND_MIN | :1183 | **0.55** | 否（人格）|
| A3 | pop ≥ EXPAND_MIN_POP | :1178 | **8** | 間接（farming→pop 長）|
| A4 | effective_food ≥ pop × FOOD_PER_PERSON × **7 日** | :1179-1180 | FOUND_FOOD_SURPLUS_DAYS=**7** | ⚠ **部分**——farming 抬 food,但**要 7 日盈餘 buffer 非只糊口**,pop 成長吃掉 → 可能仍不達 |
| A5 | path_ok = **可達獨立鄰盟友** ally_id≠-1 | :1181,1166 | — | ✗ **farming 無關** |
| A6 | not busy | :1183 | — | 間接 |

**A 執行**：建國贏 → 結盟 primary（ally_util≥subj_util）→ **派信使(envoy)送提案**（:1209 `_dispatch_envoy`）→ 對方 **belief-based 接受**（pending_proposal，:1122）→ `create_faction`。或征服路（打贏 subjugate）。**多日 gauntlet**：攢 → 找盟 → 信使往返（`_founding_timeout` :1238）→ 接受。

## 階段 B：faction → established（`faction_ai:974-980`，立國 gate）
faction 組成後（≥2 成員）才進此門。**同時**滿足才 emit「立國」goal → `_declare_established:3349` 設 is_established：
| # | 條件 | file:line | 常數 |
|---|---|---|---|
| B1 | not established AND member_team_ids ≥ **2** | :974 | 2 |
| B2 | leader 統領 skill ≥ ESTABLISH_COMMAND − ambition_discount | :977 | 0.4 −(野心−0.5)×0.2 |
| B3 | 野心 ≥ ESTABLISH_AMBITION − 0.1 | :978 | **0.6** |
| B4 | **leader_team.readiness ≥ ESTABLISH_READINESS** | :979 | **0.7** ← 硬檻 |

## ★真根候選（farming 解食物後，established 仍 0 = 卡在這些）
食物非唯一根,farming 只碰 A3(間接)/A4(部分)。**farming 無關的門**：
1. **A5 path_ok（可達獨立盟友）**：結盟建國需另一獨立隊在可達範圍。world-gen §1 scatter 散開 + 獨立隊死/入 faction → **可達獨立鄰稀** → 建國 intent 有意願卻無路徑。
2. **A4 7 日食物盈餘 buffer**（非糊口）：farming 抬產但 pop 成長吃掉 → 攢不出 7 日 surplus。
3. **B4 readiness ≥ 0.7**：掙扎求生隊 readiness（戰備，飢餓/戰鬥耗）難達 0.7。就算組成 faction 也 established 不了。
4. **多階段時間常數**：A（攢+找盟+信使往返+接受）+ B（組隊後 readiness 爬到 0.7）= 多日多階 gauntlet;12mo 窗含月1 急性危機+月10 二次惡化 → 窗太緊。

## ★measure-first：probe 已 instrument,直接指哪門（免新 characterize）
建國 gate funnel probe **已存在**（:1185-1194）——**measurer 讀 de-patch acceptance run 的既有 probe 即知哪門擋**：
- `indep.gate_ambitious`（A2 過的分母）
- `indep.gate_fail_pop`（A3 卡）/ `indep.gate_fail_food`（A4 卡）/ `indep.gate_fail_busy`（A6）/ `indep.gate_fail_nopath`（**A5 卡=可達盟友**）/ `indep.gate_path_ok`（全 A 過）
- `indep.found_ally`（派信使結盟）/ `indep.found_timeout`（信使/提案逾時）
- 階段 B 無專屬 fail probe → **建議 measurer 補一個**（立國 gate 三條 B2/B3/B4 各 fail 計數），或先看 A 門 funnel（若 A 就卡光,B 不用查）。

∴ **不必新猜**——measurer 從既有 probe funnel 定位 established=0 的實際斷點（A5? A4? 還是 A 過了卡 B4?），再 spec 對症。這是 measure-first（先量哪門,再開藥）。

## 序建議
1. measurer 讀 de-patch run 的 `indep.gate_fail_*` funnel（+ 補 B 門 probe）→ 定位實際斷門 → to:blueprint。
2. 定位後你 brainstorm 對症（若 A5=可達盟友稀 → founding 路徑放寬/降盟友距離/允單隊立國?；若 A4=盈餘 buffer → 門檻/farming 產能;若 B4=readiness → establishment readiness 檻）→ 對抗 → spec。
3. 這與 measurer 標的「長程週期（月1急性+月10二次惡化）」可能共享時間常數根,一起看。

farming 是地基第一塊,established 真根在上面這些門。probe 已備,measure-first 定位即知。
