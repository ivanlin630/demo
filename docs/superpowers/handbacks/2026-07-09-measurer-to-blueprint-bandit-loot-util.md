---
from: measurer
to: blueprint
status: open
topic: 職業搶匪量測結果——0/409征服意圖選掠奪，loot_lead峰值全0.00（機會型搶匪不存在）
---

# 職業搶匪湧現否——量測結果

main HEAD(dbcd0fc，已含 shipped 純fold)，3 seed(1337/42/7)，3月。數字檔：`docs/process/verdicts/A2c1.loot_probe.json`。
新增 debug bed `scripts/debug/a2c1_loot_probe_bed.gd`（沿用 WarringHarness，零 sim 邏輯變）。

## 結論先講：機會型職業搶匪不存在
| seed | conq.intent（決策點） | winner=掠奪 | loot_lead峰值 |
|---|---|---|---|
| 1337 | 53 | **0** | 0.00 |
| 42 | 339 | **0** | 0.00 |
| 7 | 17 | **0** | 0.00 |
| **合計** | **409** | **0/409 (0.0%)** | **全0.00** |

3 seed、409 個征服意圖決策點，**掠奪 option 一次都沒贏過**。`loot_lead_peak`（掠奪util − 次佳option util 的最大領先幅度）三seed皆 0.00——不是「偶爾贏、fed隊才贏」，是**從未領先過次佳選項**。這不是樣本不夠，是掠奪util目前設計上限就低於其他option基準線，結構性選不到。

## 做不到的部分（誠實揭露，非硬幹）
- **fed/starve 分層做不到**：要在 `faction_ai_system.gd` 決策當下讀 food_flow/days_left 標記，需改 scripts/simulation（鐵律5禁）。反正 winner_loot=0，分層也是全0，語意上不影響結論。
- **無分布只有峰值**：現有 `Probe.note()` 只存單run內max，非per-event log。

## ★重要區分（別混淆）
本探針只測「**征服分支機會型掠奪**」（`_probe_conq_winner`，util 競秤下的機會 option）。另有獨立的「**絕境生存掠奪**」（`surv.loot_dispatch`，飢餓 override 路徑）**不在本次範圍**——那條線先前 full_probe 量到有活動量（如純fold baseline seed1337=32次派遣）。若你問的是「划算就搶(非絕境)」→答案否定；若問「廣義搶劫存在否(含絕境)」→那條線是活的，需另量。

## 你判
「世界現有沒有山賊經濟」——機會型(吃飽搶)：無，且不是邊緣案例是結構性零。若要發展山賊經濟方向，util 公式（掠奪的 term 權重/上限）需調整才有機會湧現，非現況微調可解。是否當設計方向、要不要調公式，判準在你。
