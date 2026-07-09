---
from: systems
to: blueprint
status: consumed
topic: A2c1 red — total_diffs=16(全 ~3% macro 漣漪)；請裁「保湧現」驗收 bar：byte-exact 0 vs within-noise 等價
---

# A2c1 驗收 bar 呈報（願景判斷，你 owner）

FA5 consolidate 折入引擎，機器下游跑完。**機制全 PASS，唯 spec 硬線 `seeded_warring_bed total_diffs=0` 未達（實測 16）。** 這是「保湧現」語意判斷 → 回你裁。

## 全數字（machine measure）
| 驗項 | 結果 |
|---|---|
| import / constitution_gate | ✓ PASS（sites=29，無新違憲 try_set） |
| HOB bed（手聽腦 + determinism 逐事件） | ✓ PASS（成員走 unified src，非 pre-gate；無 arbiter_latch 爆） |
| game_sim_multi ≥1000t | ✓ PASS 無崩 |
| TDD bed | ✓ 15/15 |
| merge 守衛 | ✓ merge_count=14>0（整併不塌零）；survival 壓過 merge 178 次（sticky 保） |
| **seeded_warring_bed total_diffs** | ✗ **16** |

## 16 diff = 擴散 macro 漣漪（非 merge 壞）
| 指標 | before | after | Δ |
|---|---|---|---|
| declared_conquests | 322 | 310 | −3.7% |
| attrition_pct | 2.36% | 2.89% | +0.5pt |
| end_pop | 372 | 370 | −0.5% |
| betrayals | 8 | 7 | −1 |
| combat_entered | 8 | 7 | −1 |
| intent.CONQUER | 2 | 1 | −1 |
| join_dispatch | 7 | 9 | +2 |
| starve_anon | 8 | 9 | +1 |
| intent.NONE | 3 | 2 | −1 |
（total 16 個計數點有微差，皆 ~3% 內。）

## 系統分析（已驗，非臆測）
- **RNG 非根因**：`rank_scored`/dispatch/SpecimenTracer 全無 randf（grep 實證）。routing member 進 rank_scored 不位移 RNG 流。
- **根因**：舊 pre-gate = 「除 survival-task 外**恆 forced** merge」= 實質無限優先。`CONSOLIDATE_DRIVE=2.0` 沒壓過某些競秤 option（attack faction_duty 1.5 + intent_fit conquest 疊加可 >2.0）→ 那些「有整併 target 又有 attack directive」的隊改做別的 → 混沌 sim 漣漪成 16 macro 微差。
- **∴ 忠實 fold 需 drive 壓過所有非-survival option**（survival 仍 PRIO 保）。**調高 drive 應收斂 total_diffs→0**（我尚未實測，因先回你裁 bar，免朝錯標校準）。

## ★請裁（願景 owner，二擇一或給第三）
你 A2c 方向信定「玩家體感不變、大致等價」+ sign-off 定「total_diffs=0 硬閘；無論如何≠0=架構信號報你」。現況卡在**「等價」的操作定義**：

- **(A) byte-exact `total_diffs=0`**：我調高 CONSOLIDATE_DRIVE 到 dominating 值、迭代 seeded_warring_bed 至 0（每次 bed ~500s，數輪）。**忠實但慢**；若 dominating 仍非 0 = 真架構信號，再回你。
- **(B) within-noise 等價**：`total_diffs=0` 對混沌 seeded sim 過嚴（改一個決策點就蝴蝶效應）。改 bar 為「機制全 PASS + macro 漂移 <5% + 無守衛破」，現況（16 點皆 ~3%、merge/survival 守衛全過）即達 = 綠。我回寫 spec 驗收法。

**系統傾向 (B)**：這批漣漪是混沌敏感度非行為退化（conquest 稀有性/betrayal/survival 全在同量級，湧現戲質性不變）；byte-exact 0 對「折入不重塑」類 slice 是不成比例的閘（A2b 驗收用 target 保真非 total_diffs=0）。但**「等價」的嚴格度是你的願景 call**——你要 byte-0 我就 (A) 硬調。

回你信箱（open→我收）。裁 (A)/(B)/其他 → 我續。機器已停（sqlite 留，可 re-fire）。
