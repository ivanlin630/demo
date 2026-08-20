---
from: measurer
to: systems
status: consumed
topic: labor-slice-gate-verdict
---

# labor-slice gate：★★★決定性gate FAIL——斷崖沒治好，根因是 demand 分母沒跟著改

ticket:`2026-08-18-systems-to-measurer-labor-slice-gate.md`
數字全落地:`docs/measurements/2026-08-18-labor-slice-gate.measure.json`
床:`scripts/debug/labor_slice_perteam_bed.gd`（temp、已刪）；seed=1337 peaceful_economy.json 6個月，`feat/labor-marginal-food`(02db6096)。

## ⑥headless full-run → 綠
`--import`重建快取後跑 `headless_test.gd`：0 assertion failures，獨立確認 implementer 的 9/9+0-new。

## ★★★決定性gate=治斷崖 → **FAIL**

| farming_level | 修前(FUY per-team輪) | 修後(labor-slice) |
|---|---|---|
| 1 | 0.267 | 0.164 |
| 2 | 0.103 | 0.058 |
| 3 | 0.067 | 0.038 |

**斷崖沒被治好**——修後仍是同樣陡的單調負相關，L3/L1 相對陡峭度前後幾乎一樣（0.251→0.232），而且絕對值全面更低（不是變平或翻正，是整條線下移）。ticket 要求的「farm 高 level 拿多份」沒發生。

## 根因：demand 分母沒跟著改

我讀了 `labor_system.gd:56`：

```gdscript
demand["farm"] = float(tile.farming_level) * K_FARM
```

這行**這輪 diff 完全沒動**。T1 只改了 `_workstation_need` 的 weight 算法（新 `_food_group_need`：`food_need × yield_f/(yield_g+yield_f)`）。問題是：

- weight 分子：`yield_f = level×FARM_UNIT_YIELD×harvest` 隨 level 長大沒錯，但當 level 夠高時 `yield_f` 支配 `yield_g`，weight 會**漸進趨近 food_need 這個有限上限**、不再繼續隨 level 長大。
- demand 分母：`level×K_FARM` **無界線性成長**，沒有任何飽和機制。

`fill = 分配到的量/demand`——分子有界、分母無界線性成長，數學上 fill 必然隨 level 增加而下降。這解釋了為什麼斷崖幾乎原封不動：**這輪只調了 weight 這一側，沒調 demand 這一側**，而 demand 這一側才是造成 level 越高越填不滿的直接機制。

## 結論

不是校準問題（不是「調參數就好」），是 **T1 的邏輯結構性缺口**：只改 weight-side 分配比例，沒動 demand-side 隨 level 無界成長的分母，兩者不對齊導致決定性 gate 沒過。要真正治斷崖，demand["farm"] 這條線本身需要跟著某種飽和/非線性設計調整（例如 K_FARM 不再是純線性乘 level 的常數，或改成跟 yield 掛勾的形式），單改 weight 側救不了。

## 其餘 gate

由於★★★決定性 gate 已 FAIL，我沒有繼續往下驗①guns-vs-butter②cross-resource③估算器誠實④broad-effects⑤determinism 這些其餘項——這些都是建立在「斷崖已治好」前提上的次要驗證，決定性 gate 沒過就不必燒時間驗周邊，等 implementer 修完 demand 側再一次性重驗。

建議退回 implementer：demand["farm"] 需要跟 weight 側同步調整，非目前這樣「只調分子不調分母」。
