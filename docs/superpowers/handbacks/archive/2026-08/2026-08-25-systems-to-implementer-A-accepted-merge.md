---
from: systems
to: implementer
status: consumed
slice: harvest-terrain-from-regen
topic: ★A 四條全 PASS,ACCEPTED → 跑憲法閘 + 融合驗 → merge;★③是主結果(day000-only → 貫穿 90 天且中段有峰)
---

# A ACCEPTED —— 四條全 PASS

| # | 判準 | 結果 |
|---|---|---|
| ① | 手工對照表消失 | **PASS** —— `RES_HARVEST_TERRAIN` 窮盡 grep **只剩 1 處註解**，已被 `harvest_terrains()` **動態導出**取代 |
| ② | `food` 卡點歸零 | **PASS** —— **不可採桶 ＝ `[]`**，候選 **0 → 249** |
| ★③ | **時間分佈質變** | ★★**PASS（主結果）** —— `day000`～`day086` **貫穿全 90 天**，中段 `day032`-`037` 有峰（**34/31/28**） |
| ④ | 反向：`material` 不退化 | **PASS（抽驗 10/76，非窮盡，誠實邊界已標）** |

## ★★③ 為什麼是主結果，而且「有峰」比「均勻」更好
**`day000-only` → 貫穿 90 天** ＝ **質變**，不是量變。
★**而中段有峰（不是平坦噪音）本身是因果合理性的證據**：
**資源要先累積，才會出現大量建材需求** ⇒ **峰落在中段，而非開頭或均勻散佈，符合機制該有的形狀。**
★**平坦分佈反而會讓我懷疑那只是把常數換成另一個常數。**

## ⇒ 下一步（你做）
1. **`.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`**（憲法閘）
2. **融合驗 / framework 綠**
3. **綠才 merge `feat/harvest-terrain-from-regen` → `main`**
4. ★**merge 前 `git diff --stat` 掃帶入檔**（`HELD work別共worktree` 血證）

## ★順帶：`config/peaceful_economy_factioned.json` 我已補進 `main`
三個 worktree 的版本 **`md5` 完全相同**（`3bfeca85...`）⇒ 直接扶正，**你 merge 時若衝突以 `main` 為準**（內容一樣，只是位置）。
**那張「床只活在 worktree」的欠票，我這邊結掉了。**
