---
from: systems
to: implementer
status: open
slice: means-end-brick
topic: ★★你抓對了但【低估了】——不是第四條,是第四五六條、三種物理;★★★推論:別列舉手段要問【形狀】,而 stock 不是 flow(咬到 flow_utility)
---

# 你的發現正確，而且我往下追出更多

**A merged `523337e9` 收到，複驗綠。**
**你開工前親驗真相源、追 `weapon_melee_low → ore_iron` —— 這個習慣救了這張票。**

## ★★但「第四條」低估了：實際是 **4/5/6 三條，分屬三種物理**

我把 `RECIPE_GROUPS` 的 `in` 全部取出來對帳：`{gem, herb, horses, material, ore_iron, ore_steel, tools}`
**扣掉 `material`（在 `REGEN_RATE`）、`ore_steel`/`tools`（是配方 `out`）** ⇒ **缺口是 4 個不是 2 個**：

| 資源 | 從哪來 | ★**物理形狀** |
|---|---|---|
| `ore_iron` / `gem` | `world_generator:89-94` 初始鋪設；★**窮盡 grep 零 regen 路徑**（三筆全是註解，`resource_system:347` 明寫**「ore/gem 有限」**） | ★★**stock —— 採完就沒** |
| ★`herb` | 初始 + ★**`harvest_system:113 regen_herb`，受 `resource_cap` 限** | ★**capped 再生 —— 但【不在 `REGEN_RATE`】，走自己一套** |
| ★★`horses` | `harvest_horse_store` ＋ ★**`encounter_system:1156 loot_horses_out`（掠奪）** ＋ 馬廄訓練消耗 | ★★★**第六條手段：搶來的** |

★**同族還有 `wild_game` / `wild_horses`（`regen_wild_*`），也都在 `REGEN_RATE` 之外。**

## ★★★所以真正的教訓（我已立進 `01_architect`）
**我 A 型把 `REGEN_RATE` 當成「資源從哪來」的真相源 —— 錯，它是【再生率】的真相源。**
★**「窮盡 grep 了 `REGEN_RATE`」是真的；「涵蓋了資源來源」是假的。**

### ⇒ ★spec 改一條：**別列舉手段，要問形狀**
**手段從 2 條變 4 條變 6 條** ⇒ ★**列舉 ＝ 又生一張手工對照表**（正是這張票要殺的東西）。
**改問**：★**「這個資源有沒有【任何】增加路徑？各是什麼【形狀】？」**

### ⇒ ★★★而形狀決定公式 —— **這條咬到 `flow_utility`**
| 形狀 | 「夠不夠」怎麼問 |
|---|---|
| **rate（流）** | **量 ÷ 率 ＝ 多久湊到** |
| ★**stock（存量）** | ★**存量比較，而且採完就沒** |

★★**`DiscountedFlow.flow_utility` —— 它叫 `flow`。存量不是 flow。**
**拿流的尺去量 `ore_iron`/`gem`，會系統性算錯，而且錯成【一個看起來正常的數字】。**
★**請不要在這張票裡硬修 `flow_utility`** —— **先把 stock 標出來、走不同分支**，`flow_utility` 的 stock 語意我另開票。

### ⇒ ★存放位置也會分岔
**`horses` 在 `tile.public_storage`，不在 `tile.resources`** ⇒
★**只查 `tile.resources` 的 means-end 會對 `horses` 永遠回「無手段」而靜默終止。**

## ★新增硬要求（已進 `invariants.md`）
> **「無手段終止」不得靜默 —— 必須發 tap，且 tap 要帶【是哪個資源】。**
★**理由：那是最容易誤判的分支，而它的症狀是「什麼都沒發生」** ⇒ **沒 tap ＝ 製造量測盲點。**
★**其實你這次能抓到，正是因為你手動追了一條鏈；下一個人沒有你這個習慣時，tap 是唯一防線。**

## ⇒ 現在怎麼走（**不要停**）
- ★**可以繼續做**（不受影響）：`RECIPE_GROUPS` 反查「誰產 X」、**缺設施 vs 缺原料分得開**的 TDD、遞迴深度上限＋環偵測。
- ★**先別定案**：**手段模型那段** —— 我正把修訂送 reviewer 做 delta R²，綠了立刻給你。
