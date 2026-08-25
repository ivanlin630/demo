---
from: systems
to: implementer
status: open
slice: means-end-brick
topic: ★R² CLEAN → dispatch;真相源 = manufacturing_system.gd:35-60 RECIPE_GROUPS(我親開驗過,鏈深≥3 不是假設);★★估工時禁手抄 rate 常數
---

# dispatch：`docs/superpowers/specs/2026-08-25-means-end-brick-HOW.md`

**R² CLEAN**（reviewer 三點全親驗：**92% ＝ 事件數**、**真相源已存在不需新手工表**、**感知鐵律結構上守住**）。
**A 型已 ACCEPTED**，B 是同一條供應鏈的另一半 —— **A 是 `food`，B 是占 92% 的製造品。**

## ★我自己開檔驗過真相源，而且**比 reviewer 說的更強**
`RECIPE_GROUPS` 的每筆同時給你 **means-end 三段**：

| 你要的 | 資料裡是 | 例 |
|---|---|---|
| **目標** | `out` | `"out": "goods"` |
| **前置資源依賴** | `in` | `"in": { "material": 3.0 }`（**per-unit**） |
| ★**前置設施依賴** | ★**組的 key** | ★`"manufacturing_level"` ⇒ **沒工坊就不是「缺料」而是「缺設施」** |

★★**而且鏈深 ≥ 3 是【資料裡真的有】，不是假設**：
`weapon_melee_high` **需要 `ore_steel`** ⇒ `ore_steel` **本身是 `smelter_level` 的 `out`** ⇒ **它又需要 `ore_iron` + `material`**。
⇒ ★**`ore_steel` 同時出現在 `out` 和 `in` 兩側** —— **遞迴不是為了漂亮，是資料逼出來的。**
★**請確保遞迴有深度上限 + 環偵測**（配方表未來可能出現環，別讓它變成 stack overflow）。

## ★★我加一條 reviewer 沒咬到的：**估工時禁手抄 `rate`**
means-end 一定會問「**做出來要多久／夠不夠**」⇒ **會碰到產率**。
★**`rate_const` 是字串名（`"GOODS_RATE"`）＝ 間接查常數** —— **這正是「估算器禁手抄物理」的高風險點。**

> **禁**：在 means-end 裡寫 `var rate := 3.0  # GOODS_RATE`
> ★**要**：**從 `ManufacturingSystem` 讀**（同 `build-eta-single-source` 的形狀 —— **改接線，不是改數值**）。

★**修法形狀＝單一身分**：**產率的權威只有一個，means-end 是它的 consumer，不是第二份抄本。**

## ★交付閘
1. **TDD**：先寫「**缺設施** vs **缺原料**分得開」的測試 —— ★**這兩者的解法完全不同**（蓋工坊 vs 去採料），**分不開就等於沒做**。
2. **`estimator-lineage-scan.sh` 必須綠**（新常數會被抓）。
3. ★**驗收判準優先寫【集合型】**（`05_acceptance` 新條）：
   **「`_resolve_resource_prereq` 的『無手段可取得』桶 ＝ 空集合」** 這種，**對母體單位免疫**；
   **別寫「2089 降到多少」** —— **那是事件數，分母會墊高。**
4. **量測交接必標【已落地 exact path】**。
