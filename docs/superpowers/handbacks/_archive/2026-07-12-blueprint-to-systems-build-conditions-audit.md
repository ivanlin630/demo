---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 完整據點+設施建造條件表——修死鎖前摸清全部閘,免de-patch農場漏outpost/糧倉;誰能建×成本×地形×觸發
---

# systems：完整建造條件審計（零跑純讀，修死鎖前置）

用戶：修農場 faction-only 死鎖前,先確認**所有據點+設施的建造條件**——免得只 de-patch 農場、卻漏了 outpost/糧倉/其他食物相關建造也被鎖,修不完整。

## 要的（完整表，file:line）
對**每個可建造物**列全條件：
- **據點類**：crude camp（`establish_crude_camp`）、正規 outpost（建/升級）、outpost 類型（civilian/military）怎麼定/能不能改。
- **8 設施**：farming/workshop/apothecary/mint/stable/冶煉/武器坊/護甲坊（FACILITY_DEF）。

每項列：
| 建造物 | **誰能建**（faction/獨立隊/玩家?） | 成本（material/tools/food?） | 地形要求 | outpost 類型要求 | 觸發條件（trigger_check/threshold） | **其他閘**（faction-only? pop? 前置?） |

## 重點問題（修死鎖直接相關）
1. **哪些是 faction-only**（同農場）、哪些獨立隊也能建？—— 定 de-patch 範圍（食物鏈上還有哪些被鎖）。
2. **crude camp / 正規 outpost 獨立隊能建嗎**？（農場需 civilian outpost 為前置 → 獨立隊有沒有 outpost 是關鍵）。
3. **糧倉（granary/public_storage）怎麼生**——附據點自動有？要建？獨立隊有沒有糧倉存糧？
4. **food 相關的建造鏈完整前置**：獨立隊要有農場食物,倒推需要什麼（outpost→civilian型→material→...）,哪一環對獨立隊關。

## 為何（完整修 vs 補半）
死鎖修 = 給獨立隊食物基建路徑。但若「農場需 civilian outpost」而「outpost 建也 faction-only」,只 de-patch 農場沒用（還缺 outpost）。**要全鏈的閘一次看清,才知 de-patch 要拆幾個閘、拆哪些。**

## 序
- 零跑純讀,出完整表 to:blueprint。
- 表出來 → 我看清全鏈閘 → brainstorm 設計完整 de-patch（獨立隊食物基建 bootstrap，哪些閘要拆）→ 對抗 → spec。
- measurer 農場×存活實證平行corroborate（接現跑後）。
