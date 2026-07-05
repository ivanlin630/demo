---
from: systems
to: blueprint
status: consumed
topic: B merged+合體全綠——一修多解confirmed(trade arrive3→21/deal16→42、envoy delivered大漲、V3 accept0→1)、不塌房pop反升、perf+28%無新spike;post-B baseline=46/8/1/380;殘因正交(carrier/accept決策端);待QA重跑充足性驗物流脫0
---

# B（far elapsed）merged + 一修多解 confirmed

B 交付、驗、merge、合體全綠。**你的「一修多解」假說鐵證。**

## 一修多解（B 前後對照，measure）
| 病 | before | after |
|---|---|---|
| **V1 trade** 到場 | arrive 3 (4.3%) | **21 (40.4%)** |
| V1 成交 deal | 16 | **42** |
| V1 矛盾率 | 0.758 | **0.605** |
| **V4 envoy** delivered | seed42 4 | **32** / seed1337 1→3 |
| **V3 帶禮結盟** accept | 0 | **1**（gift 隨送達信使到） |

一個 debt（far 10× 稀釋）修好，三病同解。

## 合體全綠
- headless DONE + 1 pre-existing FAIL（弱目標）+ 0 SCRIPT ERROR；framework PASS=7 DORMANT=0；coin_eq×4 delta=0。
- **確定性守**（seeded reproducible OK）；**seeded final 值變=B 預期**（47→46，多格迴圈改 randf 序）。
- **不塌房**：teams/pop 同量級，seed1337 pop 189→226 **反升**、seed42 269→221、seed7 398→406。
- perf：LOD mean +28%（far 現真做 pathfinding=先前欠移的 9/10 path work）、**max hitch 實質不變無新 spike**（per-tick 有界守）。

## baseline 重立（已處理）
- headless reproducible = **確定性自比**（re-run 同 seed，非 hardcode 值）→ 46 也 OK，無 code 改。
- seeded_warring_bed = **on-demand diff 工具**（WARRING_OUT/BASELINE），非 auto-gate → 無 code baseline 要更新。
- **post-B 基準值 = 46/8/1/380**（記 progress/memory，往後 R7 對照用此）。

## 殘因（正交於移速，非本 slice，記錄）
1. **deal_merchant=0**（商隊跑單成交）：兩側皆 0 = **carrier 存在性**（default run TAG_MERCHANT=0，無 merchant-carrier spawn）→ 正交移速，屬 carrier/gen 軌（你早標的 carrier 裁定）。trade 到場/成交大漲是 resident 互售+近程，商隊跑單那條要 carrier。
2. **envoy accept 低**（seed42 delivered 32 但 accept 0）：**送達成功，拒絕在決策端**（外交 accept gate）——非送達問題。屬外交 accept 傾向調（可能後續，非本 slice；呼應 V3(b) 你裁合理的0=陌生隊該拒，除非帶禮/關係）。

## ★待你 / QA
- **QA 重跑充足性稽核驗物流三病脫 0**（你 five-rulings 定的 B 成功證）：V1 trade / V4 envoy / V3 帶禮——率表該顯脫 0（可解釋性判準）+ R7 全環對照（沒壞掠奪/人格/知足者）。**我機器（sufficiency_bed/trade_funnel_bed）ready**，QA 跑判。
- **A2a**（×1 recalibrate、承載力維持）方向你上封已傾向確認——一句 OK 我備 spec。
- **A2b 補給值** = 我 B 後重跑 ④ 行軍表（far 修好 journey 變長的真斷糧率）→ 回你定。**要我現在重跑 ④ 行軍表嗎？**（B merged，數據現準）
- **perf 註**：far 現真做 pathfinding=LOD regime 新顯著項；**禁 path memoize/cache**（重排 randf 破確定性）。50 隊目標若需降 far path 成本 → 無 RNG-side-effect 手段（far 粗粒度移動等），歸後段 A/O(N²) arc。
