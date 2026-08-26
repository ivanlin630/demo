---
from: systems
to: implementer
status: open
slice: old-growth-forest
tier: behavior
topic: ★R² CLEAN → 動工:老熟林(forest 高產材料點);★★★三件我先寫死,每一件都是這條 arc 上有人踩過的坑:①`chance > 0.0 and` 的短路(少了它對照組永遠不綠)②量級錨 herb 3.75× 不自己挑③resource_cap 那句註解的【定性】是延續慣例不是警告巧合
---

# spec：`docs/superpowers/specs/2026-08-26-old-growth-forest-HOW.md`（R② CLEAN）

# ★①做什麼
`world_generator.gd` 的 forest 段：**照同檔既有高產點模式，加一層「老熟林」**
（形狀比照 `HERB_RICH_CHANCE 0.05` ＋ `HERB_FOREST_CHANCE 0.30` 的兩層 roll）。
**常數具名 ＋ `TEST VALUE`，禁裸魔數。**

---

# ★★★②三件先寫死（**每一件都是這條 arc 上有人踩過的坑**）

## ★(a) 短路寫法 —— **必須，少了它對照組永遠不綠**
```gdscript
if OLD_GROWTH_CHANCE > 0.0 and rng.randf() < OLD_GROWTH_CHANCE: ...
```
★**理由**：**`rng.randf() < 0.0` 仍然是一次真實的 RNG 呼叫（只是恆假）**
⇒ ★★**seeded 序列整條往後平移一格 ⇒ 下游所有 tile 的生成全部改變**
⇒ ★★★**「比例設 0」就不再等於「沒有這張票」，而驗收 3 正是靠這個等式。**
★**這是 reviewer 在 spec 上路前接住的第三條不可達驗收** —— **前兩條是我交件後才發現的。**

## ★★(b) 量級判準 —— **錨在 herb，不要自己挑**
```
herb rich [10,20] 中值 15 ／ normal [2,6] 中值 4  ≈ 3.75×
⇒ 老熟林的「rich 中值 ÷ forest normal 中值」落在【同一個數量級】（不必剛好相等）
```
★**forest normal 是 `[80, 220]`** ⇒ **你自己算得出目標區間。**
★★**我【不給你數字】，但我給了你一個【你可以自己驗證對錯】的判準** ——
★★★**這兩件不一樣，而我上一版只做了前者（寫「要能被 organic 分布支撐」＝沒有 falsifier）。**

★**順帶撤掉我原本提的那條**：「一座老熟林足以支撐 `cost 50`」——
★★**reviewer 查出 forest 一般上限 220 早就遠超 50，連普通森林都達標 ⇒ 那是恆真式，沒有鑑別力。**

## ★(c) `resource_cap` 那句註解 —— **定性是【延續慣例】不是【警告巧合】**
`tile.resource_cap = tile.resources.duplicate()` ⇒ **初始值同時是月再生上限。**
★**這是既有設計**（`:95` herb 註解明講過；`:106-108` 野馬**顯式覆寫** cap ——
★★**那行只有在作者知道預設規則時才需要存在**）。
⇒ ★**註解比照 `:95` 的風格寫一句就好**，**不要寫成「警告未來別拆開」**，★★**也不要拆成獨立具名欄位**（herb／wild_horses 都沒那樣做）。

---

# ★③驗收
| # | 條 |
|---|---|
| 1 | `reject_cannot_afford` **顯著下降**（★**新床基線 163**，不是舊床的 180） |
| 2 | `built_in_place` **上升**（★**新床基線 23**） |
| 3 | ★★★**對照組**：`OLD_GROWTH_CHANCE = 0` ⇒ **`fp` 逐位元等於改床基線 `07285478…` 的新床值** ——★**這條靠 (a) 才可達** |
| 4 | **`fp` 會變**（worldgen 改動 ⇒ 世界不同）—— 預期 |
| 5 | 零裸魔數／`estimator-lineage-scan` 綠／headless 閘（baseline 7） |

★**驗收 1、2 的基線請用【新床】的數字** —— ★★**舊床那組（180／16）標了 `OLDBED`，跨床不可比。**

# ★④食物那一項
**`tile_food_init` 一行不要動。** ★**若餓死率上升，照原樣回報** —— **那是床照世界造之後才看得見的真問題，不是這張票做壞了。**
