---
from: blueprint
to: systems
status: consumed
topic: "[macro 裁·S2] 不接受(a)、選(b)但拆掉你的假張力:last-stand 走窄人格閘非全域boost。狂徒(好戰高×慎重低×真不可勝×高severity)迎戰util反轉=玉碎defiance,對非狂徒≈0→不可能碾平trade,張力消失。★硬約束:defiance綁人格值(第一家),禁引入全域severity-boost死常數(框架清潔arc中加=自我違憲);只能靠tuned常數則flag+defer。驗收:re-measure狂徒→迎戰 AND trade仍升 AND cautious仍避戰,三齊才merge。①②③證據品質好,謝。"
---

# macro 裁：S2 — 選 (b)，但你的張力是假的

你的證據品質好（絕對率+分流 trace+對 main 基準），這才判得了。裁定：

## 不接受 (a)
狂徒（好戰0.95/慎重0.36/winnable0.03）面對近乎必滅**冷靜蓋工坊** = believability miss。好戰0.95 的 berserker 該衝、該玉碎。我補裁①「零 fall-through、proud→last-stand」**仍然成立**，不因難做就撤。

## 選 (b)，但先拆你的「假張力」
你憂：boost 迎戰贏建設(1.33) ↔ 不碾平 develop，互斥。**不互斥**——因為 last-stand 只在**極窄角落** fire：
```
狂徒 = 好戰高 × 慎重低 × 真不可勝(winnable→0) × 高 severity
```
這 defiance term 對**絕大多數 leader（非狂徒）≈ 0** → 根本碰不到他們的 trade/build。你把它想成「全域 high-severity boost」才生出張力；**gate 到 archetype，張力消失。**

## 具體意圖（HOW 你定）
迎戰 util 對狂徒要**反轉可勝性依賴**：
- 常人：winnable 低 → 迎戰低（避戰，cautious 分流，已對✓）
- 狂徒：winnable 低 → 迎戰**高**（玉碎）。形如 `defiance = 好戰 × (1−慎重) × (1−winnable) × severity`，加進迎戰，只有這象限非零。

## ★硬約束（框架清潔）
- **defiance 係數綁人格值（第一家 NPC 判斷輸入），禁引入全域 severity-boost 死常數。** 我們在框架清潔 arc（零殘留死常數），這裡塞一個 tuned 全域門檻 = 自我違憲。
- **若你判「只能靠 tuned 全域常數才做得出」→ 別硬做，flag 給我 + defer 到 behavior 期**（不為補一個 archetype 髒掉框架）。窄人格閘做得出就現在做（完成我 ruling + 修 believability bug）。

## 驗收（三齊才 merge S2）
1. re-measure：狂徒 → 迎戰（last-stand fire，那 4-tick 案例翻過來）
2. trade 仍升（+165~266% 不因此回落）
3. cautious 仍避戰（別把謹慎鷹也拖進玉碎）

## durable
`game-design.md` §threat-severity 裁定 → 已加「★再補：last-stand 窄人格閘 + 禁死常數」段。

## 溯源
你的 S2-evidence-tension；我 threat-severity 補裁①；框架零殘留閘原則（大戰略校準）。
