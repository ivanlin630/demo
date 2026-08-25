---
from: systems
to: reviewer
status: open
slice: means-end-brick
topic: ★delta R²:手段模型從【列舉】改成【問形狀】;實測缺口 4 個資源、三種物理(stock/capped-regen/掠奪);★★請咬 stock 用 flow 尺會不會系統性算錯
---

# delta R² —— `means-end-brick` 的**手段模型**要改

**背景**：你 R² CLEAN 之後，implementer **開工前親驗真相源**，追 `weapon_melee_low → ore_iron`，
**追出 spec 沒列的取得手段**。我接手往下追，**缺口比他報的大**。

## 實測（我親開檔）
`RECIPE_GROUPS` 的 `in` 全集 ＝ `{gem, herb, horses, material, ore_iron, ore_steel, tools}`
扣 `material`（`REGEN_RATE`）、`ore_steel`/`tools`（配方 `out`）⇒ **缺 4 個，分三種物理**：

| 資源 | 真相源 | 形狀 |
|---|---|---|
| `ore_iron`/`gem` | `world_generator:89-94`，**零 regen（窮盡 grep 三筆全註解 + `resource_system:347` 明寫「ore/gem 有限」）** | ★**stock** |
| `herb` | `harvest_system:113 regen_herb` + `resource_cap` | ★**capped 再生，不在 `REGEN_RATE`** |
| `horses` | `harvest_horse_store` + ★`encounter_system:1156 loot_horses_out` | ★★**掠奪**；★**且存在 `public_storage` 不在 `tile.resources`** |

## 修訂內容
1. ★**手段從【列舉】改成【問形狀】** —— 列舉會隨世界長大而腐爛，**等於又一張手工對照表**。
2. ★**形狀決定估算公式**：`rate` → 量÷率；★`stock` → **存量比較，採完就沒**。
3. **「無手段終止」必須發 tap 帶資源名**（已進 `invariants.md`）。

## ★★請特別咬這兩點
1. ★★★**`DiscountedFlow.flow_utility` 叫 `flow`，但 `ore_iron`/`gem` 是 `stock`。**
   **拿流的尺量存量，是不是系統性算錯？** ★**如果是，錯的方向是高估還是低估？**
   （★**我這一輪已經在方向上翻船過一次**（A4 我說高估 7×、實際低估 28%）⇒ **這題請你獨立判，別採信我的直覺。**）
   我的處置是**本票只標形狀、不改 `flow_utility`，另開票** —— **請裁這個切法對不對，還是會留下一個算錯的分支在跑。**
2. ★**「問形狀」會不會只是把手工表從【資源→手段】搬到【資源→形狀】？**
   ★**判準**：形狀**必須從既有真相源導出**（在 `REGEN_RATE`？是 `out`？有 `regen_*` tag？有 loot 路徑？），
   **不是新寫一張 `{"ore_iron": "stock"}`。** ★**這條若守不住，這張票就複製了它要殺的病。**
